require 'spec_helper'


describe 'Student Course Access ' do

  let(:username) { 'abuchman'}
  let(:current_course_by_student_key) { "student/#{current_course}/#{username}"}
  let(:current_course_key) { "course/#{current_course}"}
  let(:semester_code) { '201300'}
  let(:next_semester_code) { '201310'}
  let(:current_course) { '201300_3605' }


  before(:each) do
    semester = Factory(:semester, code: semester_code)
    next_semester = Factory(:next_semester, code: next_semester_code)

    @u = FactoryBot.create(:student, username: username)
    login_as @u

    stub_ssi!
    turn_on_ldap!

    VCR.use_cassette current_course_key do
      @current_course = CourseSearch.new.get(current_course)
    end
  end


  it "Shows an avaiable book reserve" do
    res = mock_reserve FactoryBot.create(:request, :available, :book), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    # text exists
    expect(page).to have_selector('div.record-book h2.title', text: res.title)
    # is not a link
    expect(page).to_not have_selector('div.record-book h2.title a')
  end


  it "shows an available book chapter" do
    res = mock_reserve FactoryBot.create(:request, :available, :book_chapter), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    click_link(res.title)

    expect_copyright_form!(page)

    click_button('I Accept')

    expect(page.response_headers["Content-Disposition"]).to eq "attachment; filename=\"test.pdf\""
  end


  it "shows a journal with a url redirect" do
    res = mock_reserve FactoryBot.create(:request, :available, :journal_url), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    # it does something weird with the external redirect so it needs to be tested this way
    ApplicationController.any_instance.should_receive(:redirect_to).with(res.url)
    click_link(res.title)
  end


  it "shows a journal with a file attached to it" do
    res = mock_reserve FactoryBot.create(:request, :available, :journal_file), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    click_link(res.title)

    expect_copyright_form!(page)

    click_button('I Accept')

    expect(page.response_headers["Content-Disposition"]).to eq "attachment; filename=\"test.pdf\""
  end


  it "shows a video from our streaming server" do
    res = mock_reserve FactoryBot.create(:request, :available, :video), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    click_link(res.title)

    expect_copyright_form!(page)

    click_button('I Accept')

    expect(page).to have_selector("div#jwplayer")
  end


  it "does not show a request that is in the new phase" do
    res = mock_reserve FactoryBot.create(:request, :new, :book_chapter), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    expect(page).to_not have_selector('div.record-book h2.title', text: res.title)
  end


  it "does not show a request that is inprocess " do
    res = mock_reserve FactoryBot.create(:request, :inprocess, :book_chapter), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    expect(page).to_not have_selector('div.record-book h2.title', text: res.title)
  end


  it " does not show a request that is removed" do
    res = mock_reserve FactoryBot.create(:request, :removed, :book_chapter), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserves_path(@current_course.id)
    end

    expect(page).to_not have_selector('div.record-book h2.title', text: res.title)
  end


  it "allows a copyright to be canceled" do
    res = mock_reserve FactoryBot.create(:request, :available, :book_chapter), @current_course

    VCR.use_cassette current_course_by_student_key do
      visit course_reserve_path(@current_course.id, res.id)
    end

    click_link('I do not accept')

    expect(current_path).to eq course_reserve_path(@current_course.id, res.id)
  end


  def expect_copyright_form!(page)
    expect(page).to have_selector('h2', text: 'WARNING CONCERNING COPYRIGHT RESTRICTIONS')
  end
end
