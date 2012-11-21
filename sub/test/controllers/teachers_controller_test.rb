# -*- encoding : utf-8 -*-
require "test_helper"
describe TeachersController do
  before do
    @teacher = Teacher.nondeleted.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "老师创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "老师创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "老师创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "老师创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 405==@response.status
  end
    
  it "老师读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert 405==@response.status
  end
  it "老师读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert 405==@response.status
  end
    
  it "老师读取R1: show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,{:id=>@teacher.id.to_s}
    assert @response.success?
  end
  it "老师读取R1: show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,{:id=>@teacher.id.to_s}
    assert @response.success?
  end
    
  it "老师更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@teacher.id.to_s}
    assert 302==@response.status
  end
  it "老师更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@teacher.id.to_s}
    assert 405==@response.status
  end
    
  it "老师更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@teacher.id.to_s}
    assert 302==@response.status
  end
  it "老师更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,{:id=>@teacher.id.to_s}
    assert 405==@response.status
  end
    
  it "老师销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@teacher.id.to_s}
    assert 302==@response.status
  end
  it "老师销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy,{:id=>@teacher.id.to_s}
    assert 405==@response.status
  end

  it "ajax化的关注老师 - 游客状态" do
    assert @controller.current_user.nil?
    post :follow,{"id"=>@teacher.id.to_s}
    assert 401==@response.status,'游客不能发起ajax化的关注老师'
  end
  it "ajax化的关注老师" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :follow,{"id"=>@teacher.id.to_s}
    assert @response.success?,'已经登录的用户可以ajax关注老师'
  end
  it "ajax化的取消关注老师 - 游客状态" do
    assert @controller.current_user.nil?
    post :unfollow,{"id"=>@teacher.id.to_s}
    assert 401==@response.status,'游客不能发起ajax化的取消关注老师'
  end
  it "ajax化的取消关注老师" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :unfollow,{"id"=>@teacher.id.to_s}
    assert @response.success?,'已经登录的用户可以ajax取消关注老师'
  end
      
  it "老师的关注者followers - 游客状态" do
    assert @controller.current_user.nil?
      get "followers",{"id"=>@teacher.id.to_s}
    assert @response.success?
  end
  it "老师的关注者followers" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get "followers",{"id"=>@teacher.id.to_s}
    assert @response.success?
  end
    
  it "简单关注 - 游客状态" do
    assert @controller.current_user.nil?
    get :follow,{"id"=>@teacher.id.to_s}
    assert 401==@response.status
  end
  it "简单关注" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :follow,{"id"=>@teacher.id.to_s}
    assert @response.success?
  end

  it "简单取消关注 - 游客状态" do
    assert @controller.current_user.nil?
    get :unfollow,{"id"=>@teacher.id.to_s}
    assert 401==@response.status
  end
  it "简单取消关注" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :unfollow,{"id"=>@teacher.id.to_s}
    assert @response.success?
  end
  
end
