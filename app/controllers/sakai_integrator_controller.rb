class SakaiIntegratorController < ApplicationController

  def sakai_redirect
    if params[:context_id]
      si = SakaiIntegrator.new(self)
      si.site_id = params[:context_id]
      external_site_id = si.get_site_property('externalSiteId')
      section_group_id = si.translate_external_site_id(external_site_id)
      if !section_group_id.blank?
        redirect_to course_reserves_path(:course_id => section_group_id)
      else
        render_404
      end
    else
      render_404
    end
  end

end
