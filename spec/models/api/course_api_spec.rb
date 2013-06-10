require 'spec_helper'

describe CourseApi do

  let(:course_api) { CourseApi.new }
  let(:semester) { FactoryGirl.create(:semester)}

  before(:each) do
    stub_courses!
  end


  describe "api_access" do
    it "only calls the api once for enrolled and instucted courses per netid and semster"
  end


  describe "#enrolled_courses" do

    it "returns the students enrolled courses for the current semseter" do
      courses = course_api.enrolled_courses('student', 'current')
      test_result_has_course_ids(courses, ["current_21258_20334_20452_20237", "current_22555_23911", "current_22557", "current_21188", "current_21266_20113_20588", "current_23124_24550_23128", "current_25426", "current_24541_28873", "current_29157", "current_28883", "current_21015"])
    end

    it "returns the students enrolled courses for the previous semseter" do
      courses = course_api.enrolled_courses('student', 'previous')
      test_result_has_course_ids(courses, ["previous_11389", "previous_12569_12570_12574_12576", "previous_12545_12546_12547_15041_12548", "previous_18984_18985", "previous_12777_14617", "previous_13023_13024_14383_14389", "previous_11640_11641"])
    end

    it "returns the inst_stu's enrolled courses for the current semester" do
      courses = course_api.enrolled_courses('inst_stu', 'current')
      test_result_has_course_ids(courses, ["current_29898"])
    end

    it "returns the inst_stu's enrolled courses for the previous semester" do
      courses = course_api.enrolled_courses('inst_stu', 'previous')
      test_result_has_course_ids(courses, ["previous_19745", "previous_19591", "previous_20066"])
    end

    it "returns the instructors enrolled courses for the current semester" do
      course_api.enrolled_courses('instructor', 'current').size.should == 0
    end

    it "returns the instructors enrolled courses for the previous semester" do
      course_api.enrolled_courses('instructor', 'previous').size.should == 0
    end
  end


  describe "#instructed_courses" do

    it "returns the students instructed courses for the current semseter" do
      course_api.instructed_courses('student', 'current').size.should == 0
    end


    it "returns the students instructed courses for the previous semseter" do
      course_api.instructed_courses('student', 'previous').size.should == 0
    end


    it "returns the inst_stu's instructed courses for the current semester" do
      courses = course_api.instructed_courses('inst_stu', 'current')
      test_result_has_course_ids(courses, ["current_28972_28971_29901"])
    end


    it "returns the inst_stu's instructed courses for the previous semester" do
      courses = course_api.instructed_courses('inst_stu', 'previous')
      test_result_has_course_ids(courses, ["previous_18446", "previous_18448"])
    end


    it "returns the instructors instructed courses for the current semester" do
      courses = course_api.instructed_courses('instructor', 'current')
      test_result_has_course_ids(courses, ["current_21258_20334_20452_20237"])
   end


    it "returns the instructors instructed courses for the previous semester" do
      courses = course_api.instructed_courses('instructor', 'previous')
      test_result_has_course_ids(courses, ["previous_24521_24661_24522"])
    end



    describe "cross_listings" do
      it "combines the corss listed classes into one result" do
        courses = course_api.instructed_courses('crosslisting', 'current')

        courses.first.crosslistings.first.id.should == "current_11393_14611_11386_11388"
        courses.first.crosslistings.last.id.should == "current_13944_14854_13946_13947"
      end
    end
  end

  describe :get do
    it "returns the course specified" do

    end

  end




  def test_result_has_course_ids(courses, valid_ids)
    courses.size.should == valid_ids.size

    courses.each do | course |
      valid_ids.include?(course.id).should be_true
    end
  end

  def display_course_ids(courses)
    puts courses.collect { | c | c.id }.inspect
  end
end
