class StudentListingsController < ApplicationController

  layout 'external'

  def index
    reserves
  end


  def show
    @course = reserves.course(params[:id])

    if @course.nil?
      render_404
    end
  end


  protected

    def reserves
      @reserves ||= ReservesApp.new("USER")
    end

end