require "minitest_helper"

describe "Courseware Integration"  do
  it "show Courseware title" do
    cw = FactoryGirl.build(:courseware)
    visit courseware_path(cw)
    page.text.must_include "#{cw.title}" 
  end
end