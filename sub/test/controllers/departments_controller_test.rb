# -*- encoding : utf-8 -*-
require "test_helper"
describe DepartmentsController do
  before do
    @department = Department.nondeleted.gotfid.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  

  it "院系创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "院系创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "院系创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "院系创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 405==@response.status
  end
    
  it "院系读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert 405==@response.status
  end
  it "院系读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert 405==@response.status
  end
    
  it "院系读取R1: show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,{:id=>@department.id.to_s}
    assert @response.success?
  end
  it "院系读取R1: show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,{:id=>@department.id.to_s}
    assert @response.success?
  end
    
  it "院系更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@department.id.to_s}
    assert 302==@response.status
  end
  it "院系更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@department.id.to_s}
    assert 405==@response.status
  end
    
  it "院系更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@department.id.to_s}
    assert 302==@response.status
  end
  it "院系更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,{:id=>@department.id.to_s}
    assert 405==@response.status
  end
    
  it "院系销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@department.id.to_s}
    assert 302==@response.status
  end
  it "院系销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy,{:id=>@department.id.to_s}
    assert 405==@response.status
  end

  it "ajax化的关注院系 - 游客状态" do
    assert @controller.current_user.nil?
    post :follow,{"id"=>@department.fid.to_s}
    assert 401==@response.status,'游客不能发起ajax化的关注院系'
  end
  it "ajax化的关注院系" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :follow,{"id"=>@department.fid.to_s}
    assert @response.success?,'已经登录的用户可以ajax关注院系'
  end
  it "ajax化的取消关注院系 - 游客状态" do
    assert @controller.current_user.nil?
    post :unfollow,{"id"=>@department.fid.to_s}
    assert 401==@response.status,'游客不能发起ajax化的取消关注院系'
  end
  it "ajax化的取消关注院系" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :unfollow,{"id"=>@department.fid.to_s}
    assert @response.success?,'已经登录的用户可以ajax取消关注院系'
  end
    

end