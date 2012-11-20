# -*- encoding : utf-8 -*-
require "test_helper"
describe TeachersController do
  before do
    @teacher = Teacher.nondeleted.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
end
