require 'test_helper'

class PersonTest < ActiveSupport::TestCase


  test "address state must be equal to 2 characters" do
    person = FactoryGirl.create(:person)
    person.state = "M"
    assert person.invalid?, "state too short"
    person.state = "Mass"
    assert person.invalid?, "state too long"
    person.state = "MA"
    assert person.valid?
  end

  test "division 1 and division 2 must be valid" do
    person = FactoryGirl.create(:person)
    person.division1 = "Command"
    assert person.invalid?, "division2 blank when division1 entered should be invalid"
    person.division1 = ""
    person.division2 = "Command"
    assert person.invalid?, "division1 blank when division2 entered should be invalid"
    person.division1 = "Command"
    assert person.valid?
  end

  test "icsid (badge) should be unique" do
    person1 = FactoryGirl.create(:person, icsid: "509")
    person2 = FactoryGirl.create(:person)
    person2.icsid = "509"
    assert person2.invalid?, " ICSID badge duplicated."
    person2.icsid = "555"
    assert person2.valid?
  end
  
  test "driver is not skilled at driving when license expired" do
    drivingskill = FactoryGirl.create(:skill, name: "Driving")
    evoc_course = FactoryGirl.create(:course)
    evoc_course.skills << drivingskill
    
    #cert factory creates the person
    drivingcert = FactoryGirl.create(:cert, course: evoc_course, status: "Expired")
    person = drivingcert.person
    
    assert drivingcert.course.skills.include?(drivingskill)
    assert_equal false, person.skilled?('Driving')
  end

  test "driver is not skilled at barking" do
    #This tests that it is false for a skill that does exist
    skill = FactoryGirl.create(:skill, name: "Leeching")
    
    person = FactoryGirl.create(:person)    
    assert_equal false, person.skilled?('Leeching')
  end
  
  test "driver is qualified at policing" do
    #From the top, this sets up the model chain from title requiring a skill to a course 
    #and then a person having a certification from that course.
    policetitle = FactoryGirl.create(:title, name: "Police Officer")
    drivingskill = FactoryGirl.create(:skill, name: "Driving")
    policetitle.skills << drivingskill
    evoc_course = FactoryGirl.create(:course)
    evoc_course.skills << drivingskill
    #cert factory creates the person
    drivingcert = FactoryGirl.create(:cert, course: evoc_course)
    person = drivingcert.person
   
    assert_equal true, person.skilled?('Driving')
    assert_equal true, person.qualified?('Police Officer')
  end
  
  test "driver is NOT qualified at SAR" do
    #From the top
    title = FactoryGirl.create(:title, name: "SAR Team")
    landnavskill = FactoryGirl.create(:skill, name: "Land Navigation")
    title.skills << landnavskill

    drivingskill = FactoryGirl.create(:skill, name: "Driving")
    evoc_course = FactoryGirl.create(:course)
    evoc_course.skills << drivingskill
    assert evoc_course.skills.include?(drivingskill)
    
    drivingcert = FactoryGirl.create(:cert, course: evoc_course)
    person = drivingcert.person

    assert drivingcert.course.skills.include?(drivingskill)
    
    assert_equal false, person.qualified?('SAR Team')
  end

end
