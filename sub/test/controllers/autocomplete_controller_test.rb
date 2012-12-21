# -*- encoding : utf-8 -*-
require "test_helper"
describe AutocompleteController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "all - 游客状态" do
    assert @controller.current_user.nil?
      get 'all',{q:'大物'}
    assert @response.success?,'游客可以all'
  end
  it "all" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'all',{q:'大物'}
    assert @response.success?,'登录用户可以all'
  end
    

  it "swords - 游客状态" do
    assert @controller.current_user.nil?
      get 'swords',{term:'大物'}
    assert @response.success?,'游客可以swords'
  end
  it "swords" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'swords',{term:'大物'}
    assert @response.success?,'登录用户可以swords'
  end
    
  
end
