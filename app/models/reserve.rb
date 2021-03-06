class Reserve
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks

  delegate :media_playlist, :selection_title, :realtime_availability_id, :electronic_reserve, :physical_reserve, :citation, :display_length, :language_track, :subtitle_language, :metadata_synchronization_date, :on_order, :on_order?, :details, :type, :publisher, :title, :journal_title, :creator, :contributor, :length, :url, :nd_meta_data_id, :overwrite_nd_meta_data, :overwrite_nd_meta_data?, to: :item
  delegate :media_playlist=, :selection_title=, :realtime_availability_id=, :electronic_reserve=, :physical_reserve=, :citation=, :display_length=, :language_track=, :subtitle_language=, :metadata_synchronization_date=, :on_order=, :details=, :type=, :publisher=, :title=, :journal_title=, :creator=, :contributor=,:length=, :pdf, :pdf=, :url=, :nd_meta_data_id=, :overwrite_nd_meta_data=, :overwrite_nd_meta_data=, to: :item
  delegate :electronic_reserve?, :physical_reserve?, :details, :available_library, :availability, :publisher_provider, :creator_contributor, to: :item

  delegate :currently_in_aleph, :currently_in_aleph?, :reviewed?, :reviewed, :created_at, :updated_at, :id, :semester, :workflow_state, :course_id, :crosslist_id, :requestor_netid, :needed_by, :number_of_copies, :note, :requestor_owns_a_copy, :library, :requestor_netid, :required_material, :message, to: :request
  delegate :currently_in_aleph=, :reviewed=, :id=, :semester=, :workflow_state=, :course_id=, :requestor_netid=, :needed_by=, :number_of_copies=, :note=, :requestor_owns_a_copy=, :library=, :requestor_netid=, :required_material=, :message=, to: :request
  delegate :item_title, :item_selection_title, :sortable_title, :item_type, :item_physical_reserve, :item_electronic_reserve, :item_physical_reserve?, :item_electronic_reserve?, :item_on_order?, to: :request

  attr_accessor :course, :request
  attr_accessor :requestor_has_an_electronic_copy
  attr_accessor :fair_use, :requestor

  state_machine :workflow_state, :initial => :new do

    event :complete do
      transition [:new, :inprocess, :on_order, :onhold, :awaitinginfo ] => :available
    end


    event :remove do
      transition [:new, :inprocess, :available, :on_order, :onhold, :awaitinginfo ] => :removed
    end


    event :start do
      transition [:new] => :inprocess
    end


    event :restart do
      transition [:available, :removed] => :inprocess
    end


    event :purchased do
      transition [:on_order] => :inprocess
    end


    state :new
    state :inproess
    state :available
    state :removed
    state :onhold
    state :awaitinginfo
  end


  def self.factory(request, course = nil)
    self.new(request: request, course: course)
  end


  def initialize(attrs = {})
    self.attributes= attrs

    # this is required for the state_machine gem do not forget again and remove
    super()
    self.workflow_state ||= :new
  end


  def attributes=(attrs= {})
    attrs.keys.each do  | key |
      self.send("#{key}=", attrs[key])
    end
  end


  def title
    if !self.overwrite_nd_meta_data? && @item.display_length.present?
      "#{@item.title} - #{@item.display_length}"
    else
      "#{@item.title}"
    end
  end


  def requestor_name
    if requestor_netid == 'import'
      return "imported"
    end

    @user ||= requestor
    if !@user
      return ""
    end

    @user.display_name
  end


  def item
    @item ||= (request.item || request.build_item)
  end


  def item_id
    item.id
  end


  def requestor
    @user ||= User.where(:username => self.requestor_netid).first
  end


  def request
    @request ||= Request.new
  end


  def course
    @course ||= CourseSearch.new.get(self.course_id)
  end


  def fair_use
    @fair_use ||= ( FairUse.request(self).first || FairUse.new(request: request) )
  end


  def save!
    ActiveRecord::Base.transaction do
      item.save!

      request.item = item
      request.course_id = course.id
      request.semester_id = course.semester.id
      copy_item_fields

      request.save!
    end
  end

  def copy_item_fields
    [:title, :selection_title, :type, :physical_reserve, :electronic_reserve, :on_order].each do |item_field|
      request.send("item_#{item_field}=", item.send(item_field))
    end
  end

  def can_copy_reserve?
    !self.removed?
  end

  def destroy!
    if self.remove
      self.save!
    end
  end


  def persisted?
    false
  end


end
