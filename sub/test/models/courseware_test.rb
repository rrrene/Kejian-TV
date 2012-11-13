require "minitest_helper"

describe Courseware do
  it "test_to_s"  do
    cw = Courseware.first
    user = Factory.attributes_for(:user,:name=>cw.title)
    user.name.to_s.must_equal "#{cw.title}"
  end
end
