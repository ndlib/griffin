class RequestReservesController < ApplicationController

  layout 'external'

  def new
    @request_reserve = course.new_request_reserve
  end


  def create

  end


  protected

    def reserves
      @reserves ||= ReservesApp.new("USER")
    end


    def course
      @course ||= reserves.course(params[:prof_listing_id])
    end
end