# -*- encoding : utf-8 -*-
require "test_helper"
describe CoursesController do
  before do
    @course = Course.nondeleted.gotfid.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "课程创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "课程创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "课程创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "课程创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 405==@response.status
  end
    
  it "课程读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert @response.success?
  end
  it "课程读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert @response.success?
  end
    
  it "课程读取R1: show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,{:id=>@course.id.to_s}
    assert @response.success?
  end
  it "课程读取R1: show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,{:id=>@course.id.to_s}
    assert @response.success?
  end
    
  it "课程更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@course.id.to_s}
    assert 302==@response.status
  end
  it "课程更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@course.id.to_s}
    assert 405==@response.status
  end
    
  it "课程更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@course.id.to_s}
    assert 302==@response.status
  end
  it "课程更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,{:id=>@course.id.to_s}
    assert 405==@response.status
  end
    
  it "课程销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@course.id.to_s}
    assert 302==@response.status
  end
  it "课程销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy,{:id=>@course.id.to_s}
    assert 405==@response.status
  end
  it "ajax化的关注课程 - 游客状态" do
    assert @controller.current_user.nil?
    post :follow,{"id"=>@course.fid.to_s}
    assert 401==@response.status,'游客不能发起ajax化的关注课程'
  end
  it "ajax化的关注课程" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :follow,{"id"=>@course.fid.to_s}
    assert @response.success?,'已经登录的用户可以ajax关注课程'
  end
  it "ajax化的取消关注课程 - 游客状态" do
    assert @controller.current_user.nil?
    post :unfollow,{"id"=>@course.fid.to_s}
    assert 401==@response.status,'游客不能发起ajax化的取消关注课程'
  end
  it "ajax化的取消关注课程" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :unfollow,{"id"=>@course.fid.to_s}
    assert @response.success?,'已经登录的用户可以ajax取消关注课程'
  end
       
end