class ReserveResourcePolicy

  def initialize(reserve)
    @reserve = reserve
  end


  def can_have_file_resource?
    return true if ['JournalReserve', 'BookChapterReserve'].include?(@reserve.type)

    false
  end


  def has_file_resource?
    can_have_file_resource? && @reserve.pdf.present?
  end


  def reserve_file_path
    @reserve.pdf.path
  end


  def can_have_url_resource?
    return true if ['JournalReserve', 'VideoReserve', 'AudioReserve'].include?(@reserve.type)

    false
  end


  def streaming_server_redirect?
    ['VideoReserve', 'AudioReserve'].include?(@reserve.type)
  end


  def has_url_resource?
    can_have_url_resource? && @reserve.url.present?
  end


  def can_be_linked_to?
    @reserve.semester.current? && ( has_file_resource? || has_url_resource? )
  end

end
