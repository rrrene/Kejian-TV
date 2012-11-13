require "minitest_helper"

describe Courseware do
  it "test_to_s"  do
    cw = FactoryGirl.build(:courseware)
    user = FactoryGirl.build(:user)
    user.name.must_equal "#{cw.title}"
  end
end
