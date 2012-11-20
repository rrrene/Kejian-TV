# -*- encoding : utf-8 -*-
require "test_helper"
describe MineController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "游客在课件管理器什么都访问不了" do
    assert @controller.current_user.nil?
    get :index
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :dashboard
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_coursewares
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :view_all_playlists
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_coursewares_copyright
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
  	get :my_history
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
  	get :my_search_history
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_watch_later_coursewares
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_favorites
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_liked_coursewares
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
    assert @controller.current_user.nil?
    get :my_liked_lists
    assert 302==@response.status,'游客状态：游客【不能】进入课件管理器'
  end
  it 'index' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert @response.success?
  end
  it 'dashboard' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :dashboard
    assert @response.success?
  end
  it 'my_coursewares' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_coursewares
    assert @response.success?
  end
  it 'view_all_playlists' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :view_all_playlists
    assert @response.success?
  end
  it 'my_coursewares_copyright' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_coursewares_copyright
    assert @response.success?
  end
	it 'my_history' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_history
    assert @response.success?
  end
	it 'my_search_history' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_search_history
    assert @response.success?
  end
  it 'my_watch_later_coursewares' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_watch_later_coursewares
    assert @response.success?
  end
  it 'my_favorites' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_favorites
    assert @response.success?
  end
  it 'my_liked_coursewares' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_liked_coursewares
    assert @response.success?
  end
  it 'my_liked_lists' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :my_liked_lists
    assert @response.success?
  end
end