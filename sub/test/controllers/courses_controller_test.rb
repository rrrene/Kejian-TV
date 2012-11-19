# -*- encoding : utf-8 -*-
require "test_helper"
describe CoursesController do
  before do
    @course = Course.nondeleted.gotfid.first
  end
end