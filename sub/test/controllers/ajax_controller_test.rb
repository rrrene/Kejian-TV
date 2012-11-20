# -*- encoding : utf-8 -*-
require "test_helper"
describe AjaxController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
end