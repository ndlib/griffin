class WowzaUrlGenerator

  attr_reader :type, :username, :ipaddress, :specific_token

  def initialize(filename, type, username, ipaddress, specific_token = false)
    @filename = filename
    @type = type
    @username = username
    @ipaddress = ipaddress
    @specific_token = specific_token
  end


  def html5
    "http://#{base_url}#{filename}/playlist.m3u8?#{token}"
  end


  def rtmp
    "rtmpt://#{base_url}#{filename}?#{token}"
  end


  def rtsp
    "rtsp://#{base_url}#{filename}?#{token}"
  end


  private

    def wowza_token
      @wowza_token ||= WowzaTokenGenerator.generate(username, ipaddress).token
    end


    def token
      if specific_token
        "t=#{specific_token}"
      else
        "t=#{wowza_token}"
      end
    end


    def filename
      "#{type}:#{@filename}"
    end


    def type
      if @type == 'audio'
        'aod/_definst_/mp3'
      elsif @type == 'video'
        'vod/mp4'
      else
        raise "Invalid type, #{@type} passed into WowzaUrlGenerator"
      end
    end


    def base_url
      if Rails.env == 'production'
        "wowza.library.nd.edu:1935/"
      else
        "wowza-pprd-vm.library.nd.edu:1935/"
      end
    end
end
