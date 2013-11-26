# -*- encoding : utf-8 -*-
require "test_helper"
describe AccountSessionsController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it "账号登录new - 游客状态" do
    # GET /resource/sign_in
    assert @controller.current_user.nil?
    get :new
    assert @response.success?,'游客是可以登录'
  end
  it "账号登录new" do
    # GET /resource/sign_in
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 302==@response.status,'已经登录的用户不可以登录'
  end
  it "账号登录create - 游客状态" do
    # POST /resource/sign_in
    assert @controller.current_user.nil?
    params = {"userEmail"=>"dsfa@adfssda.com", "userPassword"=>"pmqpmq", "userKeepLogin"=>"on"}
    post :create,params
    assert @response.success?,'游客是可以提交登录的'
  end
  it "账号登录create" do
    # POST /resource/sign_in
    denglu! @user
    assert @controller.current_user.id==@user.id
    params = {"userEmail"=>"dsfa@adfssda.com", "userPassword"=>"pmqpmq", "userKeepLogin"=>"on"}
    post :create,params
    assert 302==@response.status,'已经登录的用户不可以提交登录'
  end
  it "账号登录destroy - 游客状态" do
    # DELETE /resource/sign_out
    assert @controller.current_user.nil?
    delete :destroy
    assert @controller.current_user.nil?,'可以退出'
  end
  it "账号登录destroy" do
    # DELETE /resource/sign_out
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy
    assert @controller.current_user.nil?,'可以退出'
  end

end
