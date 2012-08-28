require 'spec_helper'

describe "Video Workflow Integration" do

  before(:all) do
    @faculty_user_a = Factory.create(:user)
    @faculty_user_b = Factory.create(:user, :username => Rails.configuration.rspec_uid)
    @faculty_role = Factory.create(:faculty_role)
    @faculty_user_a.roles = [@faculty_role]
    @faculty_user_b.roles = [@faculty_role]
    @current_semester = Factory.create(:semester)
    @next_semester = Factory.create(:semester, :date_begin => Date.today + 3.months, :date_end => Date.today + 6.months)
    @distant_semester = Factory.create(:semester, :date_begin => Date.today + 7.months, :date_end => Date.today + 12.months)
    @old_semester = Factory.create(:semester, :date_begin => Date.today - 6.months, :date_end => Date.today - 2.months)
    @request_a = Factory.create(:generic_request, :semester_id => @current_semester.id, :user_id => @faculty_user_a.id)
    @request_b = Factory.create(:generic_request, :needed_by => Date.today + 4.weeks, :semester_id => @current_semester.id, :user_id => @faculty_user_b.id, :library_owned => false)
    @request_c = Factory.create(:generic_request, :needed_by => Date.today + 14.days, :semester_id => @current_semester.id, :user_id => @faculty_user_b.id)
    @media_admin_role = Factory.create(:media_admin_role)
    @media_admin_user = Factory.create(:user)
    @media_admin_user.roles = [@media_admin_role]
    @jane_user = Factory.create(:user)
  end

  describe "Change video workflow state and attributes via edit screen" do
    before :each do
     login_as @media_admin_user 
    end
    after :each do
      logout @media_admin_user
    end
    it "displays the correct request record info on edit screen" do
      visit edit_admin_request_path(@request_b)
      find_field('Title').value.should eq(@request_b.title)
      find_field('Course').value.should eq(@request_b.course)
      find_field('Needed By').value.should eq(@request_b.needed_by.to_s)
      find_field('Special Instructions').value.should eq(@request_b.note)
      find_button('Save').value.should eq('Save')
    end
    it "marks the video as library owned" do
      visit edit_admin_request_path(@request_b)
      find_field('Library Owns?').checked?.should be_false
      check('Library Owns?')
      click_button('Save')
      visit edit_admin_request_path(@request_b)
      find_field('Library Owns?').value.should be_true
    end
    it "transitions workflow state to awaiting_acquisitions" do
      visit edit_admin_request_path(@request_b)
      find('#current_state').text.should eq('New')
      select 'Requested from Acquisitions', :from => 'Transition To'
      click_button('Save')
      visit edit_admin_request_path(@request_b)
      find('#current_state').text.should eq('Awaiting Acquisitions')
    end
    it "changes the needed by date" do
      visit edit_admin_request_path(@request_b)
      find_field('Date Needed By').value.should eq(@request_b.needed_by.to_s)
      fill_in 'Date Needed By', :with => Date.today + 6.weeks
      click_button('Save')
      visit edit_admin_request_path(@request_b)
      find_field('Date Needed By').value.should eq((Date.today + 6.weeks).to_s)
    end
    it "modifies the special instructions" do
      visit edit_admin_request_path(@request_b)
      find_field('Special Instructions').value.should eq(@request_b.note)
      fill_in 'Special Instructions', :with => 'New Instructions'
      click_button('Save')
      visit edit_admin_request_path(@request_b)
      find_field('Special Instructions').value.should eq('New Instructions')
    end
    it "changes the title" do
      visit edit_admin_request_path(@request_b)
      find_field('Video Title').value.should eq(@request_b.title)
      fill_in 'Video Title', :with => 'Brand new title'
      click_button('Save')
      visit edit_admin_request_path(@request_b)
      find_field('Video Title').value.should eq('Brand new title')
    end
    it "deletes a request record" do
      visit edit_admin_request_path(@request_b)
      expect {
        click_link('Delete')
      }.to change(Request, :count).from(3).to(2)
      current_path.should eq(admin_video_request_all_path)
    end
  end

  describe "Utilize ajax information tools", :js => true do
    before :all do
      Capybara.default_wait_time =5 
      Capybara.current_driver = :selenium
    end
    before :each do
     login_as @media_admin_user 
    end
    after :each do
      logout @media_admin_user
    end
    it "views the requester informaion" do
      visit edit_admin_request_path(@request_b)
      click_link('Requester Info')
      wait_until{ page.has_content?('Requester Information') }
      page.should have_content(@request_b.user.username)
    end
  end

  describe "Utilize aspects of the video workflow lists" do
    before :each do
     login_as @media_admin_user 
    end
    after :each do
      logout @media_admin_user
    end
    it "views the new request list"
    it "views the sent to acquisitions list"
    it "accesses the request edit screen"
      # visit admin_video_request_processed_path
      # click_link(@request_a.id.to_s)
      # current_path.should eq(edit_admin_request_path(@request_a))
    it "marks a video as digitized"
    it "views requester information for request"
    it "reorders the list by title"
    it "reorders the list by request date"
    it "reorders the list by needed by date"
  end

end
