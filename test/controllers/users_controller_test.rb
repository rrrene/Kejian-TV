# -*- encoding : utf-8 -*-
require "test_helper"
describe UsersController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "用户创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "用户创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "用户创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "用户创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 405==@response.status
  end
    
  it "用户读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert 405==@response.status
  end
  it "用户读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert 405==@response.status
  end
    
  it "用户读取R1: show - 游客状态" do
    user_profile_view_count = @user.profile_view_count
    assert @controller.current_user.nil?
    get :show,:id => @user.id
    assert 200==@response.status,'游客可以查看普通用户的profile页面'
    @user.reload
    assert user_profile_view_count + 1 == @user.profile_view_count,'用户的profile页被人看了，应该profile_view_count+1'
  end
  it "用户读取R1: show" do
    user_profile_view_count = @user.profile_view_count
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:id => @user.id
    assert 200==@response.status,'登录了的用户可以查看普通用户的profile页面'
    @user.reload
    assert user_profile_view_count + 1 == @user.profile_view_count,'用户的profile页被人看了，应该profile_view_count+1'
  end
    
  it "用户更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@user.id.to_s}
    assert 302==@response.status
  end
  it "用户更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@user.id.to_s}
    assert 405==@response.status
  end
    
  it "用户更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@user.id.to_s}
    assert 302==@response.status
  end
  it "用户更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,{:id=>@user.id.to_s}
    assert 405==@response.status
  end
    
  it "用户销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@user.id.to_s}
    assert 302==@response.status
  end
  it "用户销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy,{:id=>@user.id.to_s}
    assert 405==@response.status
  end

  it "ajax化的关注用户 - 游客状态" do
    assert @controller.current_user.nil?
    post :fol,{"q"=>"1010,10101010", "nocache"=>"143"}
    assert 401==@response.status,'游客不能发起ajax化的关注'
  end
  it "ajax化的关注用户" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :fol,{"q"=>"1010,10101010", "nocache"=>"143"}
    assert @response.success?,'已经登录的用户可以ajax关注好多用户'
  end
  it "ajax化的取消关注用户 - 游客状态" do
    assert @controller.current_user.nil?
    post :unfol,{"q"=>"1010,10101010", "nocache"=>"143"}
    assert 401==@response.status,'游客不能发起ajax化的取消关注'
  end
  it "ajax化的取消关注用户" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :unfol,{"q"=>"1010,10101010", "nocache"=>"143"}
    assert @response.success?,'已经登录的用户可以ajax取消关注好多用户'
  end


  it "zm风格的ajax化关注用户 - 游客状态" do
    assert @controller.current_user.nil?
    post :zm_follow,{"id"=>User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id.to_s}
    assert 401==@response.status
  end
  it "zm风格的ajax化关注用户" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :zm_follow,{"id"=>User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id.to_s}
    assert @response.success?
  end

  it "zm风格的ajax化取消关注用户 - 游客状态" do
    assert @controller.current_user.nil?
    post :zm_unfollow,{"id"=>User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id.to_s}
    assert 401==@response.status
  end
  it "zm风格的ajax化取消关注用户" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :zm_unfollow,{"id"=>User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id.to_s}
    assert @response.success? 
  end
  
  it "简单关注 - 游客状态" do
    assert @controller.current_user.nil?
    get :follow,{"id"=>@user.id.to_s}
    assert 401==@response.status
  end
  it "简单关注" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :follow,{"id"=>@user.id.to_s}
    assert @response.success?
  end

  it "简单取消关注 - 游客状态" do
    assert @controller.current_user.nil?
    get :unfollow,{"id"=>@user.id.to_s}
    assert 401==@response.status
  end
  it "简单取消关注" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :unfollow,{"id"=>@user.id.to_s}
    assert @response.success?
  end
    

  it "查看关注用户的人followers - 游客状态" do
    assert @controller.current_user.nil?
      get "followers",{:id=>@user.id.to_s}
    assert @response.success?,'游客可以followers'
  end
  it "查看关注用户的人followers" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get "followers",{:id=>@user.id.to_s}
    assert @response.success?,'登录用户可以followers'
  end
    

  it "查看用户的关注following - 游客状态" do
    assert @controller.current_user.nil?
      get "following",{:id=>@user.id.to_s}
    assert @response.success?,'游客可以following'
  end
  it "查看用户的关注following" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get "following",{:id=>@user.id.to_s}
    assert @response.success?,'登录用户可以following'
  end
    

  it "查看用户的邀请invites - 游客状态" do
    assert @controller.current_user.nil?
      get "invites",{:id=>@user.id.to_s}
    assert @response.success?,'游客可以invites'
  end
  it "查看用户的邀请invites" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get "invites",{:id=>@user.id.to_s}
    assert @response.success?,'登录用户可以invites'
  end
    

  it "查看用户的学习伙伴double_follow - 游客状态" do
    assert @controller.current_user.nil?
      get "double_follow",{:id=>@user.id.to_s}
    assert @response.success?,'游客可以double_follow'
  end
  it "查看用户的学习伙伴double_follow" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get "double_follow",{:id=>@user.id.to_s}
    assert @response.success?,'登录用户可以double_follow'
  end
    

end
