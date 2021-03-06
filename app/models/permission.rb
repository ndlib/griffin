class Permission
 attr_reader :current_user, :controller

  def initialize(current_user, controller)
    @current_user = current_user
    @controller = controller
  end

  def current_user_views_all_courses?
    UserCanViewAllCoursesPolicy.new(current_user).can_view_all_courses?
  end

  def current_user_is_administrator?
    UserIsAdminPolicy.new(current_user).is_admin?
  end


  def current_user_is_admin_in_masquerade?
    m = Masquerade.new(controller)
    m.masquerading? && UserIsAdminPolicy.new(m.original_user).is_admin?
  end


  def current_user_instructs_course?(course)
    UserRoleInCoursePolicy.new(course, current_user).user_instructs_course? || current_user_is_administrator?
  end


  def current_user_enrolled_in_course?(course)
    course_in_current_semester?(course) && UserRoleInCoursePolicy.new(course, current_user).user_enrolled_in_course?
  end


  private

    def course_in_current_semester?(course)
      course.semester.current?
    end

end
