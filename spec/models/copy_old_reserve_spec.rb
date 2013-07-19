require 'spec_helper'

describe CopyReserve do

  let(:semester) { FactoryGirl.create(:semester) }
  let(:user) { mock_model(User, id: 1, username: 'username' )}
  let(:to_course) { double(Course, id: 'course_id', semester: semester, crosslist_id: 'crosslist_id') }

  describe :generic_copy do
    before(:each) do
      old_reserve = mock_model(OpenItem, item_type: 'chapter', location: 'test.pdf', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "1 - 2", journal_name: "journal" )
      @new_reserve = CopyOldReserve.new(user, to_course, old_reserve).copy
    end


    it "sets the book chapter title" do
      @new_reserve.title.should == "title"
    end


    it "sets the workflow state to new " do
      @new_reserve.workflow_state.should == "new"
    end


    it "sets the creator of the work" do
      @new_reserve.creator.should == "fname lname"
    end


    it "sets the overwrite_nd_meta_data to true" do
      @new_reserve.overwrite_nd_meta_data?.should be_true
    end


    it "sets the journal_title" do
      @new_reserve.journal_title.should == "journal"
    end


    it "sets the pages " do
      @new_reserve.length.should == "1 - 2"
    end

  end


  describe :copy_book do
    before(:each) do
      old_reserve = mock_model(OpenItem, item_type: 'book', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "", journal_name: "", sourceId: 'sid' )

      @new_reserve = CopyOldReserve.new(user, to_course, old_reserve).copy
    end

    it "sets the type correctly" do
      @new_reserve.type.should == "BookReserve"
    end


    it "sets the metadata id " do
      @new_reserve.nd_meta_data_id.should == "sid"
    end
  end


  describe :copy_book_chapter do
    before(:each) do
      old_reserve = mock_model(OpenItem, item_type: 'chapter', location: 'test.pdf', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "1 - 2", journal_name: "" )

      @new_reserve = CopyOldReserve.new(user, to_course, old_reserve).copy
    end

    it "sets a pdf for download" do
      @new_reserve.pdf.present?.should be_true
    end


    it "sets the type correctly " do
      @new_reserve.type.should == "BookChapterReserve"
    end
  end


  describe :copy_journal do
    before(:each) do
      @old_reserve = mock_model(OpenItem, item_type: 'article', location: 'test.pdf', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "1 - 2", journal_name: "" )
    end

    it "sets the type correctly for articles" do
      new_reserve = CopyOldReserve.new(user, to_course, @old_reserve).copy
      new_reserve.type.should == "JournalReserve"
    end


    it "sets the type correctly for journals" do
      @old_reserve.stub(:item_type).and_return('journal')
      new_reserve = CopyOldReserve.new(user, to_course, @old_reserve).copy
      new_reserve.type.should == "JournalReserve"
    end


    it "gets a pdf when the article has a pdf associated with it" do
      new_reserve = CopyOldReserve.new(user, to_course, @old_reserve).copy
      new_reserve.pdf.present?.should be_true
    end


    it "copies a url when the article has a url" do
      @old_reserve.stub(:location).and_return('')
      @old_reserve.stub(:url).and_return('http://www.google.com')

      new_reserve = CopyOldReserve.new(user, to_course, @old_reserve).copy
      new_reserve.url.should == 'http://www.google.com'
    end
  end



  describe :copy_video do
    before(:each) do
      old_reserve = mock_model(OpenItem, item_type: 'video', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "", journal_name: "", sourceId: 'sid' )

      @new_reserve = CopyOldReserve.new(user, to_course, old_reserve).copy
    end

    it "sets the type correctly" do
      @new_reserve.type.should == "VideoReserve"
    end


    it "sets the metadata id " do
      @new_reserve.nd_meta_data_id.should == "sid"
    end
  end




  describe :copy_music do
    before(:each) do
      old_reserve = mock_model(OpenItem, item_type: 'music', title: "title", author_firstname: "fname", author_lastname: "lname", pages: "", journal_name: "", sourceId: 'sid' )

      @new_reserve = CopyOldReserve.new(user, to_course, old_reserve).copy
    end

    it "sets the type correctly" do
      @new_reserve.type.should == "AudioReserve"
    end


    it "sets the metadata id " do
      @new_reserve.nd_meta_data_id.should == "sid"
    end
  end


end