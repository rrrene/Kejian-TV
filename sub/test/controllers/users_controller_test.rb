# -*- encoding : utf-8 -*-
require "test_helper"
describe UsersController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "show - 游客状态" do
    user_profile_view_count = @user.profile_view_count
    assert @controller.current_user.nil?
    get :show,:id => @user.id
    assert 200==@response.status,'用户冒烟R1 - 游客可以查看普通用户的profile页面'
    @user.reload
    assert user_profile_view_count + 1 == @user.profile_view_count,'用户的profile页被人看了，应该profile_view_count+1'
  end
  it "show" do
    user_profile_view_count = @user.profile_view_count
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:id => @user.id
    assert 200==@response.status,'用户冒烟R1 - 登录了的用户可以查看普通用户的profile页面'
    @user.reload
    assert user_profile_view_count + 1 == @user.profile_view_count,'用户的profile页被人看了，应该profile_view_count+1'
  end
end