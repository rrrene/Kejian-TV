# -*- encoding : utf-8 -*-
require "test_helper"
describe CoursesController do
  before do
    @course = Course.nondeleted.gotfid.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
end