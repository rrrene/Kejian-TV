# -*- encoding : utf-8 -*-
require "test_helper"

# To be handled correctly this spec must end with "Acceptance Test"
describe "先发制人人系列功能 Acceptance Test" do
  # it "must be a real test" do
  #   flunk "Need real tests"
  # end

=begin
  it "register_huanyihuan - 游客状态" do
    assert @controller.current_user.nil?
      get 'register_huanyihuan'
    assert 401==@response.status,'游客不能register_huanyihuan'
  end
  it "register_huanyihuan" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'register_huanyihuan'
    assert @response.success?,'登录用户可以register_huanyihuan'
  end    
 

  it "renren_invite - 游客状态" do
    assert @controller.current_user.nil?
      post 'renren_invite'
    assert 401==@response.status,'游客不能renren_invite'
  end
  it "renren_invite" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'renren_invite'
    assert @response.success?,'登录用户可以renren_invite'
  end

  it "renren_huanyizhang - 游客状态" do
    assert @controller.current_user.nil?
      post 'renren_huanyizhang'
    assert 401==@response.status,'游客不能renren_huanyizhang'
  end
  it "renren_huanyizhang" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'renren_huanyizhang'
    assert @response.success?,'登录用户可以renren_huanyizhang'
  end
    

  it "renren_real_bind - 游客状态" do
    assert @controller.current_user.nil?
      post 'renren_real_bind'
    assert 401==@response.status,'游客不能renren_real_bind'
  end
  it "renren_real_bind" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'renren_real_bind'
    assert @response.success?,'登录用户可以renren_real_bind'
  end
    

=end

  
end