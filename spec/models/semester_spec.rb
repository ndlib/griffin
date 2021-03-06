require 'spec_helper'

describe Semester do

  before(:all) do
    @current_semester = FactoryBot.create(:semester, :code => 'code', :date_end => Date.today + 90.days)
    @next_semester = FactoryBot.create(:semester, :code => 'code1', :date_begin => Date.today + 91.days, :date_end => Date.today + 290.days)
    @distant_semester = FactoryBot.create(:semester, :code => 'code2', :date_begin => Date.today + 291.days, :date_end => Date.today + 490.days)
    @last_semester = FactoryBot.create(:semester, :code => 'code3', :date_begin => Date.today - 6.months, :date_end => Date.today - 1.days)
  end

  it do
    @current_semester.should be_valid
  end

  it "should have both a code and a full name" do
    @current_semester.full_name.should_not be_nil
    @current_semester.code.should_not be_nil
  end


  it "should report an error if code or full name are blank" do
    @bad_semester = FactoryBot.build(:semester, :code=> '', :full_name => '')
    @bad_semester.code = ''
    @bad_semester.should have_at_least(1).error_on(:full_name)
    @bad_semester.should have_at_least(1).error_on(:code)
  end


  context "which is proximate" do
    it "should be the current or one of next two future semesters" do
      @current_semester.should be_proximate
      @distant_semester.should_not be_proximate
    end

    it "can be found in an array of proximate semesters" do
#      [@current_semester, @next_semester, @last_semester, @distant_semester].each { |s| s.save }
#      Semester.proximates.should include(@last_semester, @current_semester, @next_semester)
#      Semester.proximates.should_not include(@distant_semester)
    end
  end


  it "gets the next semester" do
    @current_semester.next.should == @next_semester
  end


  it "can get all the semesters before a semster " do
    semesters = Semester.semesters_before_semester(@next_semester)
    semesters.size.should == 2
    semesters.include?(@current_semester).should be_truthy
    semesters.include?(@last_semester).should be_truthy
  end


  it "can determine if it is the current semester" do
    @current_semester.current?.should be_truthy
    @next_semester.current?.should be_falsey
    @distant_semester.current?.should be_falsey
    @last_semester.current?.should be_falsey
  end


  it "can determine if it is in the future" do
    @current_semester.future?.should be_falsey
    @next_semester.future?.should be_truthy
    @distant_semester.future?.should be_truthy
    @last_semester.future?.should be_falsey
  end
end
