class CopyReserve


  def initialize(course_to, reserve)
    @course_to = course_to
    @reserve = reserve
  end


  def copy
    new_request = @reserve.request.dup

    new_request.course_id = @course_to.id
    new_request.crosslist_id = @course_to.crosslist_id

    new_request.semester  = @course_to.semester
    new_request.topics    = []
    new_request.save!

    Reserve.factory(new_request, @course_to)
  end

end
