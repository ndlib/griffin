class Admin::RequestsMetaDataController  < ApplicationController

  layout 'admin'

  def edit
    @request = reserves.reserve(params[:id])
  end


  def update
    @request = reserves.reserve(params[:id])

    if (@request.needs_external_source?)
      redirect_to edit_resource_path(@request.id)
    else
      redirect_to requests_path(@request.id, :filter => @request.status)
    end
  end


  protected

    def reserves
      @reserves ||= ::ReservesAdminApp.new(params[:semester], "current_user")
    end

end
