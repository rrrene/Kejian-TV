# -*- encoding : utf-8 -*-
require "test_helper"
describe DepartmentsController do
  before do
    @department = Department.nondeleted.gotfid.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
end