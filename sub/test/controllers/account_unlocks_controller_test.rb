# -*- encoding : utf-8 -*-
require "test_helper"
describe AccountUnlocksController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it "账号解锁new - 游客状态" do
    # GET /resource/unlock/new
    assert @controller.current_user.nil?
    get :new
    assert @response.success?,'游客是可以解锁账号'
  end
  it "账号解锁new" do
    # GET /resource/unlock/new
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 302==@response.status,'已经登录的用户不可以进行unlock系列操作'
  end
  it "账号解锁create - 游客状态" do
    # POST /resource/unlock
    assert @controller.current_user.nil?
    params={"user"=>{"email"=>"email#{Time.now.to_i}#{rand}@nonexist.com"}}
    post :create,params
    assert @response.success?,'游客是可以提交解锁账号'
  end
  it "账号解锁create" do
    # POST /resource/unlock
    denglu! @user
    assert @controller.current_user.id==@user.id
    params={"user"=>{"email"=>"email#{Time.now.to_i}#{rand}@nonexist.com"}}
    post :create,params
    assert 302==@response.status,'已经登录的用户不可以进行unlock系列操作'
  end
  it "账号解锁show - 游客状态" do
    # GET /resource/unlock?unlock_token=abcdef
    assert @controller.current_user.nil?
    get :show,:unlock_token=>'abcdef'
    assert @response.success?,'游客是可以实际进行解锁账号'
  end
  it "账号解锁show" do
    # GET /resource/unlock?unlock_token=abcdef
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:unlock_token=>'abcdef'
    assert 302==@response.status,'已经登录的用户不可以进行unlock系列操作'
  end

end
