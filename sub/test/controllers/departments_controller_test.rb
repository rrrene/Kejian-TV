# -*- encoding : utf-8 -*-
require "test_helper"
describe DepartmentsController do
  before do
    @department = Department.nondeleted.gotfid.first
  end
end