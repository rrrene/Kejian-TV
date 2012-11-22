# -*- encoding : utf-8 -*-
require "test_helper"
describe SearchController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first        
  end

  it "index - 游客状态" do
    assert @controller.current_user.nil?
      get 'index'
    assert @response.success?,'游客可以index'
      get 'index',{q:'大物'}
    assert 302==@response.status,'登录用户可以index'
  end
  it "index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'index'
    assert @response.success?,'登录用户可以index'
      get 'index',{q:'大物'}
    assert 302==@response.status,'登录用户可以index'
  end
    

  it "show - 游客状态" do
    assert @controller.current_user.nil?
      get 'show',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show'
  end
  it "show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show'
  end
    

  it "show_contents - 游客状态" do
    assert @controller.current_user.nil?
      get 'show_contents',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show_contents'
  end
  it "show_contents" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show_contents',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show_contents'
  end
    

  it "show_playlists - 游客状态" do
    assert @controller.current_user.nil?
      get 'show_playlists',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show_playlists'
  end
  it "show_playlists" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show_playlists',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show_playlists'
  end
    

  it "show_courses - 游客状态" do
    assert @controller.current_user.nil?
      get 'show_courses',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show_courses'
  end
  it "show_courses" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show_courses',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show_courses'
  end
    

  it "show_teachers - 游客状态" do
    assert @controller.current_user.nil?
      get 'show_teachers',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show_teachers'
  end
  it "show_teachers" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show_teachers',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show_teachers'
  end
    

  it "show_users - 游客状态" do
    assert @controller.current_user.nil?
      get 'show_users',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'游客可以show_users'
  end
  it "show_users" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'show_users',{"per_page"=>"10", "q"=>"大物"}
    assert @response.success?,'登录用户可以show_users'
  end
    

  it "lucky - 游客状态" do
    assert @controller.current_user.nil?
      get 'lucky',{"q"=>"大物"}
    assert @response.success?,'游客可以lucky'
  end
  it "lucky" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'lucky',{"q"=>"大物"}
    assert @response.success?,'登录用户可以lucky'
  end
    

end
