require 'spec_helper'

describe WowzaUrlGenerator do
  let(:filename) { 'filename.mov' }

  context 'audio' do
    subject { described_class.new(filename, 'audio', "username", "ipaddress") }

    describe "token generated" do
      before(:each) do
        subject.stub(:token).and_return("t=token")
      end

      it "returns html5 url " do
        expect(subject.html5).to eq("https://wowza-pprd.library.nd.edu:443/vod/_definst_/mp3:StreamingAudio/MP3/filename.mov/playlist.m3u8?t=token")
      end


      it "returns rtmp url" do
        expect(subject.rtmp).to eq("rtmpt://wowza-pprd.library.nd.edu:443/vod/?t=tokenmp3:StreamingAudio/MP3/filename.mov")
      end


      it "returns rtsp url" do
        expect(subject.rtsp).to eq("rtsp://wowza-pprd.library.nd.edu:443/vod/mp3:StreamingAudio/MP3/filename.mov?t=token")
      end
    end

    describe "token passed in" do
      subject { described_class.new(filename, 'audio', "username", "ipaddress", "passedintoken") }

      it "uses the token I specifically send in" do
        expect(subject.html5).to eq("https://wowza-pprd.library.nd.edu:443/vod/_definst_/mp3:StreamingAudio/MP3/filename.mov/playlist.m3u8?t=passedintoken")
      end
    end
  end

  context 'video' do
    subject { described_class.new(filename, 'video', "username", "ipaddress") }

    describe "token generated" do
      before(:each) do
        subject.stub(:token).and_return("t=token")
      end

      it "returns html5 url " do
        expect(subject.html5).to eq("https://wowza-pprd.library.nd.edu:443/vod/_definst_/mp4:All Streamed Videos/filename.mov/playlist.m3u8?t=token")
      end


      it "returns rtmp url" do
        expect(subject.rtmp).to eq("rtmpt://wowza-pprd.library.nd.edu:443/vod/?t=tokenmp4:All Streamed Videos/filename.mov")
      end


      it "returns rtsp url" do
        expect(subject.rtsp).to eq("rtsp://wowza-pprd.library.nd.edu:443/vod/mp4:All Streamed Videos/filename.mov?t=token")
      end
    end

    describe "token passed in" do
      subject { described_class.new(filename, 'video', "username", "ipaddress", "passedintoken") }

      it "uses the token I specifically send in" do
        expect(subject.html5).to eq("https://wowza-pprd.library.nd.edu:443/vod/_definst_/mp4:All Streamed Videos/filename.mov/playlist.m3u8?t=passedintoken")
      end
    end
  end
end
