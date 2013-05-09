
class ReservesAdminApp

  def initialize(semester, current_user)
    @semester = semester
    @current_user = current_user
  end


  def in_complete_reserves
    all_reserves.select { | r | r.status != 'complete' }
  end


  def completed_reserves
    all_reserves.select { | r | r.status == 'complete' }
  end


  def all_reserves
    ReservesApp.reserve_test_data.collect { | r | AdminReserve.new(r, @current_user) }
  end


  def reserve(id)
    AdminReserve.new(ReservesApp.reserve_test_data[id.to_i - 1], @current_user)
  end


  def netid_instructed_courses(netid, semester)
    all_courses = API::Person.courses(netid, '201210')

    all_courses['instructed_courses']
  end


  def all_courses

  end

end
