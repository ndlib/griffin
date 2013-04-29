  require 'spec_helper'

describe Reserve do

  let(:course_listing) { Reserve.new() }

  describe "attribute fields" do

    it "has a title" do
      course_listing.respond_to?(:title).should be_true
    end


    it "has a creator" do
      course_listing.respond_to?(:creator).should be_true
    end


    it "has a journal title" do
      course_listing.respond_to?(:journal_title).should be_true
    end


    it "has a length" do
      course_listing.respond_to?(:length).should be_true
    end


    it "has a file" do
      course_listing.respond_to?(:file).should be_true
    end


    it "has a url" do
      course_listing.respond_to?(:url).should be_true
    end


    it "has note" do
      course_listing.respond_to?(:note).should be_true
    end


    it "has a css class for the record display" do
      course_listing.respond_to?(:css_class)
    end


    describe :tags do

      it "has tags" do
        course_listing.respond_to?(:tags).should be_true
      end
    end


    describe :discovery do

      describe :title do

        it "returns the title from the discovery api if the record is connected." do
          VCR.use_cassette 'discovery/book' do
            course_listing = Reserve.new(discovery_id: "book", title: "not real title")
            course_listing.title.should == "Book."
          end

        end


        it "returns title stored in the request if there is no discovery_id" do
          course_listing = Reserve.new( title: "title")

          course_listing.title.should == "title"
        end
      end


      describe :creator_contributor do

        it "returns the creator_contributor from the discovery api if the record is connected" do
          VCR.use_cassette 'discovery/book' do
            course_listing = Reserve.new(discovery_id: "book", creator: "not creator")
            course_listing.creator_contributor.should == "Ronnie Wathen 1934-."
          end
        end


        it "returns the author in the request if there is no discovery id" do
          course_listing = Reserve.new( creator: "creator")

          course_listing.creator_contributor.should == "creator"
        end

      end


      describe :publisher_provider do

        it "returns the publisher_provider from the discovery api if the record is connected" do
          VCR.use_cassette 'discovery/book' do
            course_listing = Reserve.new(discovery_id: "book", journal_title: "title")
            course_listing.publisher_provider.should == "s.l. : s.n. 1968"
          end
        end


        it "returns the author in the request if there is no discovery id" do
          course_listing = Reserve.new( journal_title: "title")

          course_listing.publisher_provider.should == "title"
        end

      end


      describe :availability do

        it "returns the availability from the discovery api if the record is connected" do
          VCR.use_cassette 'discovery/book' do
            course_listing = Reserve.new(discovery_id: "book")
            course_listing.availability.should == "Available"
          end
        end


        it "returns the author in the request if there is no discovery id" do
          course_listing = Reserve.new( )

          course_listing.availability.should == ""
        end

      end


      describe :available_library do

        it "returns the available_library from the discovery api if the record is connected" do
          VCR.use_cassette 'discovery/book' do
            course_listing = Reserve.new(discovery_id: "book")
            course_listing.available_library.should == "Notre Dame, Hesburgh Library General Collection (PR 6073 .A83 B6 )"
          end
        end


        it "returns the author in the request if there is no discovery id" do
          course_listing = Reserve.new( )

          course_listing.available_library.should == ""
        end

      end

    end

    describe :discovery_api do

      it "returns builds a discvo"
    end
  end
end
