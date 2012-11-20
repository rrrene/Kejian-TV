# -*- encoding : utf-8 -*-
require "test_helper"

describe AccountController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it "账号new - 游客状态" do
    # GET /resource/sign_up
    assert @controller.current_user.nil?
    get :new
    assert @response.success?,'游客是可以注册的'
  end
  it "账号new" do
    # GET /resource/sign_up
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 302==@response.status,'已经登录的用户就不能再注册了'
  end
  it "账号create - 游客状态" do
    # POST /resource
    assert @controller.current_user.nil?
    params = {"user"=>{"name"=>"_sdfjkldfaskjddsfjdsfklsdf", "email"=>"pmq#{Time.now.to_i}#{(rand*1000).to_i}@qq.com", "password"=>"pmqpmq", "password_confirmation"=>"pmqpmq2"}}
    post :create,params
    assert @response.success?,'游客是可以提交注册的'
  end
  it "账号create" do
    # POST /resource
    denglu! @user
    assert @controller.current_user.id==@user.id
    params = {"user"=>{"name"=>"_sdfjkldfaskjddsfjdsfklsdf", "email"=>"pmq#{Time.now.to_i}#{(rand*1000).to_i}@qq.com", "password"=>"pmqpmq", "password_confirmation"=>"pmqpmq2"}}
    post :create,params
    assert 302==@response.status,'已经登录的用户就不能再提交注册了'
  end
  it "账号edit - 游客状态" do
    # GET /resource/edit
    assert @controller.current_user.nil?
    get :edit
    assert 302==@response.status,'没有登录的用户不能编辑用户'
  end
  it "账号edit" do
    # GET /resource/edit
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit
    assert @response.success?,'登录的用户可以编辑自己的个人信息'
  end
  it "账号update - 游客状态" do
    # PUT /resource
    assert @controller.current_user.nil?
    params = {"user"=>{"name"=>"潘旻琦", "email"=>"pmq2001@gmail.com", "password"=>"pmqpmq2", "password_confirmation"=>"pmqpmq", "location"=>"北京市海淀区紫竹院街道", "website"=>"http://ofpsvr.org", "tagline"=>"Kejian.TV首席技术官", "bio"=>"I hate algebra."}}
    put :update,params
    assert 302==@response.status,'没有登录的用户不能提交编辑用户'
  end
  it "账号update" do
    # PUT /resource
    denglu! @user
    assert @controller.current_user.id==@user.id
    params = {"user"=>{"name"=>"潘旻琦", "email"=>"pmq2001@gmail.com", "password"=>"pmqpmq2", "password_confirmation"=>"pmqpmq", "location"=>"北京市海淀区紫竹院街道", "website"=>"http://ofpsvr.org", "tagline"=>"Kejian.TV首席技术官", "bio"=>"I hate algebra."}}
    put :update,params
    assert @response.success?,'登录的用户可以提交编辑自己的个人信息'
  end
  it "账号destroy - 游客状态" do
    # DELETE /resource
    assert @controller.current_user.nil?
    delete :destroy
    assert 302==@response.status,'没有登录的用户不能尝试删除用户'
  end
  it "账号destroy" do
    # DELETE /resource
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy
    assert 401==@response.status,'非管理员【不能】删除用户'
  end        
  it "账号cancel - 游客状态" do
    # GET /resource/cancel
    assert @controller.current_user.nil?
    get :cancel
    assert 302==@response.status,'没有登录的用户可以cancel它的session'
  end
  it "账号cancel" do
    # GET /resource/cancel
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :cancel
    assert 302==@response.status,'登录的用户不能cancel它的session'
  end
end
