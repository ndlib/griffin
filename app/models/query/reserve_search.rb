
class ReserveSearch

  attr_accessor :relation

  def initialize( relation = Request.all )
    @relation = relation
  end


  def get(id, course = nil)
    load_in_reserve(@relation.find(id), course)
  end


  def all_reserves_for_course(course)
    instructor_reserves_for_course(course)
  end

  def instructor_reserves_for_course(course)
    @relation.
        includes(:item).
        references(:item).
        where('course_id = ? ', course.id).
        order('items.title').
        collect { | r | load_in_reserve(r, course)}
  end


  def student_reserves_for_course(course)
    @relation.
        includes(:item).
        references(:item).
        where('course_id = ? ', course.id).
        where('requests.workflow_state = ?', 'available').
        order('items.title').
        collect { | r | load_in_reserve(r, course)}
  end


  def admin_requests(semester = false)
    search = relation.
              where('requests.semester_id IN(?)', determine_search_semesters(semester)).
              order('requests.id')

    search.collect { | r | load_in_reserve(r, false) }
  end


  def reserves_by_bib_for_course(course, bib_id)
    @relation.
      includes(:item).
      references(:item).
      where('requests.course_id = ? ', course.id).
      where('items.nd_meta_data_id = ?', bib_id).
      collect { | r | load_in_reserve(r, false) }
  end


  def reserves_by_rta_id_for_course(course, rta_id)
    @relation.
      includes(:item).
      references(:item).
      where('requests.course_id = ? ', course.id).
      where('items.realtime_availability_id = ?', rta_id).
      collect { | r | load_in_reserve(r, false) }
  end


  def reserves_for_semester(semester)
    @relation.
      includes(:item).
      references(:item).
      where('requests.semester_id = ? ', semester.id).
      collect { | r | load_in_reserve(r, false) }
  end

  private

    def determine_search_semesters(semester)
      (semester ? [semester] : Semester.future_semesters.collect { | s | s.id })
    end


    def load_in_reserve(request, course)
      course = course ? course : request.course

      Reserve.factory(request, course)
    end
end
