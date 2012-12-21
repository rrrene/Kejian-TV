# -*- encoding : utf-8 -*-
require "test_helper"
describe WelcomeController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it '带条件条转型的首页index - 游客状态' do
    assert @controller.current_user.nil?
    get :index
    assert 302==@response.status && @response.location.ends_with?('/welcome/latest'),'welcome#index冒烟：游客看首页时无条件跳转到所有课件'
  end
  it '带条件条转型的首页index' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert 302==@response.status && @response.location.ends_with?('/welcome/latest'),'welcome#index冒烟：登录用户看首页时无条件跳转到所有课件'
  end
  
  it '刚刚注册完提示要查邮箱的页面inactive_sign_up - 游客状态' do
    assert @controller.current_user.nil?    
    get 'inactive_sign_up'
    assert @response.success?
  end  
  it '刚刚注册完提示要查邮箱的页面inactive_sign_up' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get 'inactive_sign_up'
    assert @response.success?
  end

  it '手气不错shuffle - 游客状态' do
    assert @controller.current_user.nil?
    get 'shuffle'
    assert 302==@response.status
  end
  it '手气不错shuffle' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get 'shuffle'
    assert 302==@response.status
  end

  it '全部课件latest - 游客状态' do
    assert @controller.current_user.nil?
    get 'latest'
    assert @response.success?
  end
  it '全部课件latest' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get 'latest'
    assert @response.success?
  end

  it '订阅课件feeds - 游客状态' do
    assert @controller.current_user.nil?
    get 'latest'
    assert @response.success?
  end
  it '订阅课件feeds' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get 'latest'
    assert @response.success?
  end

  it "iphone app介绍页面 - 游客状态" do
    assert @controller.current_user.nil?
    get :iphone
    assert @response.success?
  end
  it "iphone app介绍页面" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :iphone
    assert @response.success?
  end
  
  
end
