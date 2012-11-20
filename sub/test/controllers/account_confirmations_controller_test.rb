# -*- encoding : utf-8 -*-
require "test_helper"

describe AccountConfirmationsController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it "账号激活new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert @response.success?,'没登陆的用户可以进入重发激活邮件的页面'
  end
  it "账号激活new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert @response.success?,'登陆了的用户可以进入重发激活邮件的页面'
  end
  it "账号激活create - 游客状态" do
    # POST /resource/confirmation
    assert @controller.current_user.nil?
    params={"user"=>{"email"=>"a@b.com"}}
    post :create,params
    assert @response.success?,'没登陆的用户可以提交激活请求'
  end
  it "账号激活create" do
    # POST /resource/confirmation
    denglu! @user
    assert @controller.current_user.id==@user.id
    params={"user"=>{"email"=>"a@b.com"}}
    post :create,params
    assert @response.success?,'登陆了的用户可以提交激活请求'
  end
  it "账号激活show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,:confirmation_token=>'abcdef'
    assert @response.success?,'没登陆的用户可以激活账号'
  end
  it "账号激活show" do
    # GET /resource/confirmation?confirmation_token=abcdef
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:confirmation_token=>'abcdef'
    assert @response.success?,'登陆了的用户可以激活账号'
  end
end
