# -*- encoding : utf-8 -*-
require "test_helper"
describe AccountPasswordsController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  it "账号忘记密码new - 游客状态" do
    # GET /resource/password/new
    assert @controller.current_user.nil?    
    get :new
    assert @response.success?,'游客可以忘记密码'
  end
  it "账号忘记密码new" do
    # GET /resource/password/new
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 302==@response.status,'已经登录的用户不可以忘记密码'
  end
  
  it "账号忘记密码create - 游客状态" do
    # POST /resource/password
    assert @controller.current_user.nil?
    params={"user"=>{"email"=>"email#{Time.now.to_i}#{rand}@nonexist.com"}}
    post :create,params
    assert @response.success?,'游客可以提交忘记密码'
  end
  it "账号忘记密码create" do
    # POST /resource/password
    denglu! @user
    assert @controller.current_user.id==@user.id
    params={"user"=>{"email"=>"pmq2001@gmail.com"}}
    post :create,params
    assert 302==@response.status,'已经登录的用户不可以提交忘记密码'
  end
  
  it "账号忘记密码edit - 游客状态" do
    # GET /resource/password/edit?reset_password_token=abcdef
    assert @controller.current_user.nil?
    get :edit,:reset_password_token=>'abcdef'
    assert @response.success?,'游客可以进入修改密码的页面，当然了，token要对'
  end
  it "账号忘记密码edit" do
    # GET /resource/password/edit?reset_password_token=abcdef
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,:reset_password_token=>'abcdef'
    assert 302==@response.status,'已经登录的用户不可以进入修改密码的页面'
  end
  
  it "账号忘记密码update - 游客状态" do
    # PUT /resource/password
    assert @controller.current_user.nil?
    params = {"user"=>{"reset_password_token"=>"abcdef", "password"=>"fjdskljdflskjfdsaljdsfalfjdaslds", "password_confirmation"=>"fjdskljdflskjfdsaljdsfalfjdaslds"}}
    put :update,params
    assert @response.success?,'游客可以提交新密码，当然了，token要对'
  end
  it "账号忘记密码update" do
    # PUT /resource/password
    denglu! @user
    assert @controller.current_user.id==@user.id
    params = {"user"=>{"reset_password_token"=>"abcdef", "password"=>"fjdskljdflskjfdsaljdsfalfjdaslds", "password_confirmation"=>"fjdskljdflskjfdsaljdsfalfjdaslds"}}
    put :update,params
    assert 302==@response.status,'已经登录的用户不可以提交新密码'
  end

  
end
