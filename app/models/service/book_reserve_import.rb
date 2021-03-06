class BookReserveImport

  attr_accessor :api_data, :errors


  def initialize(api_data)
    @api_data = api_data
    @errors = []

    validate!
  end


  def import!
    if can_import?
      reserves.each do | reserve |
        process_reserve_type

        reserve.title = bib_title
        reserve.creator = creator
        reserve.journal_title = publisher

        reserve.nd_meta_data_id = bib_id
        reserve.realtime_availability_id = realtime_availability_id
        reserve.course = course
        reserve.currently_in_aleph = true

        if reserve.needed_by.nil?
          reserve.needed_by = 2.weeks.from_now
        end

        if reserve.library.nil?
          reserve.library = 'hesburgh'
        end

        if reserve.requestor_netid.nil?
          reserve.requestor_netid = 'import'
        end

        if !reserve.nd_meta_data_id.nil?
          reserve.overwrite_nd_meta_data = false
        end


        if !success?
          return
        end

        begin
          ActiveRecord::Base.transaction do
            save_reserve!(reserve)

            ReserveCheckIsComplete.new(reserve).check!
          end
        rescue Exception => e
          add_error(e.message)
        end
      end
    end

    success?
  end


  def reserves
    return @reserve if @reserve

    if (r = ReserveSearch.new.reserves_by_bib_for_course(course, bib_id)).size > 0
      @reserve = r
    elsif (r = ReserveSearch.new.reserves_by_rta_id_for_course(course, realtime_availability_id)).size > 0
      @reserve = r
    else
      @reserve ||= [ Reserve.new ]
    end
  end


  def success?
    @errors.empty?
  end


  def course
    @course ||= CourseSearch.new.get(course_id)
  end


  def creator
    @api_data['creator']
  end


  def publisher
    @api_data['publisher']
  end


  def bib_id
    @api_data['bib_id']
  end


  def sid_id
    @api_data['sid']
  end


  def realtime_availability_id
    @api_data['doc_number']
  end


  def course_id
    @api_data['crosslist_id']
  end


  def bib_title
    @api_data['title']
  end


  def format
    @api_data['format'].downcase
  end


  private

    def add_error(msg)
      @errors << msg
    end


    def validate!
      if course.nil?
        add_error("Unable to find course #{course_id}")
      end
    end


    def can_import?
      course.present?
    end


    def save_reserve!(reserve)
      if AlephImporter::PersonalCopy.new(@api_data).personal_copy?
        reserve.overwrite_nd_meta_data = true
        reserve.metadata_synchronization_date = Time.now

        reserve.save!
      else
        ReserveSynchronizeMetaData.new(reserve).synchronize!
        reserve.save!
      end
    end


    def process_reserve_type
      reserves.each do | reserve |
        reserve_type = AlephImporter::DetermineReserveType.new(@api_data)
        reserve.type ||= reserve_type.determine_type

        if reserve.type.nil?
          add_error("format of '#{format}' not found in the list of traped formats")
          return false
        end

        reserve.electronic_reserve = reserve_type.determine_electronic_reserve(reserve)
        reserve.physical_reserve   = reserve_type.determine_physical_reserve(reserve)
      end
    end

end
