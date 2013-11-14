require 'spec_helper'


describe ReserveSynchronizeMetaData do

  describe :check_synchronized! do

    context "reserve can be synchronized " do

      before(:each) do
        course = double(Course, id: "id", crosslist_id: "crosslist_id", semester: FactoryGirl.create(:semester))
        CourseSearch.any_instance.stub(:get).and_return(course)

        @reserve = Reserve.new(nd_meta_data_id: "ndid", type: "BookReserve", requestor_netid: 'netid', course: course)

        @discovery_record = double(title: "title", creator_contributor: "creator_contributor", publisher_provider: "publisher_provider", details: "details", fulltext_available?: false, fulltext_url: "")
        DiscoveryApi.stub(:search_by_ids).and_return([ @discovery_record ])
      end

      it "synchronizes the title" do
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.title.should == "title"
      end


      it "synchonizes the creator_contributor "  do
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.creator_contributor.should == "creator_contributor"
      end


      it "synchonizes the publisher_provider"  do
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.publisher_provider.should == "publisher_provider"
      end

      it "synchronizes the details "  do
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.details.should == "details"
      end


      it "sets the metadata_synchronization_date to time.now" do
        @reserve.metadata_synchronization_date.should == nil
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.metadata_synchronization_date.to_s.should == Time.now.to_s
      end


      it "will synchronize the url if the discovery record has a full text available and the reserve is a type that can have urls" do
        @reserve.type = 'JournalReserve'
        @discovery_record.stub(:fulltext_available?).and_return(true)
        @discovery_record.stub(:fulltext_url).and_return("http://www.google.com")

        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.url.should == "http://www.google.com"
      end


      it "only synchronizes the url if it is nil " do
        @reserve.type = 'JournalReserve'
        @reserve.url = "old_url"
        @discovery_record.stub(:fulltext_available?).and_return(true)
        @discovery_record.stub(:fulltext_url).and_return("http://www.google.com")

        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
        @reserve.url.should == "old_url"
      end


      it "will not synch if the meta data should not be overwritten" do
        @reserve.overwrite_nd_meta_data = true

        ReserveSynchronizeMetaData.any_instance.should_not_receive(:synchonize!)
        ReserveSynchronizeMetaData.new(@reserve).check_synchronized!
      end


    end


    context "valid_discovery_id?" do
      before(:each) do
        course = double(Course, id: "id", crosslist_id: "crosslist_id", semester: FactoryGirl.create(:semester))
        CourseSearch.any_instance.stub(:get).and_return(course)

        @reserve = Reserve.new(nd_meta_data_id: "ndid", type: "BookReserve", requestor_netid: 'netid', course: course)

        @discovery_record = double(title: "title", creator_contributor: "creator_contributor", publisher_provider: "publisher_provider", details: "details", fulltext_available?: false, fulltext_url: "")

        ReserveSynchronizeMetaData.any_instance.stub(:needs_to_be_synchronized?).and_return(true)
      end

      it "returns true if the record is found" do
        DiscoveryApi.stub(:search_by_ids).and_return([ @discovery_record ])
        expect(ReserveSynchronizeMetaData.new(@reserve).valid_discovery_id?).to be_true
      end

      it "returns false if the record is not found" do
        DiscoveryApi.stub(:search_by_ids).and_return([ ])
        expect(ReserveSynchronizeMetaData.new(@reserve).valid_discovery_id?).to be_false
      end
    end

  end


end
