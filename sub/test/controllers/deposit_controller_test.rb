# -*- encoding : utf-8 -*-
require "test_helper"
describe DepositController do

  it "index - 游客状态" do
    assert @controller.current_user.nil?
    get 'index'
    assert 302==@response.status
  end
  
  it "index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get 'index'
    assert @response.success?,'登录用户可以index'
  end
    
end
