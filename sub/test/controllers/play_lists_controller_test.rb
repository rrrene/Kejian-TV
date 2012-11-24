# -*- encoding : utf-8 -*-
require "test_helper"
describe PlayListsController do
  before do
    @play_list=PlayList.no_privacy.destroyable.normal.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "播放列表创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "播放列表创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "播放列表创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "播放列表创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert @response.success?
  end
    
  it "播放列表读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert @response.success?
  end
  it "播放列表读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert @response.success?
  end
    
  it "播放列表读取R1: show - 游客状态" do
    views_count = @play_list.views_count
    assert @controller.current_user.nil?
    get :show,{:id=>@play_list.id.to_s}
    assert @response.success?,'播放列表冒烟R1 - 游客状态：游客能看普通播放列表'
    @play_list.reload
    assert views_count + 1 == @play_list.views_count,'播放列表冒烟R1 - 游客状态：普通播放列表被游客看了，应该views_count+1'
  end
  it "播放列表读取R1: show" do
    views_count = @play_list.views_count
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,{:id=>@play_list.id.to_s}
    assert @response.success?,'播放列表冒烟R1 - 登录用户能看普通播放列表'
    @play_list.reload
    assert views_count + 1 == @play_list.views_count,'播放列表冒烟R1 - 普通播放列表被登录用户看了，应该views_count+1'
  end
    
  it "播放列表更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@play_list.id.to_s}
    assert 302==@response.status
  end
  it "播放列表更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@play_list.id.to_s}
    assert 405==@response.status
  end
    
  it "播放列表更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@play_list.id.to_s}
    assert 302==@response.status
  end
  it "播放列表更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    @play_list.ua(:user_id,@user.id)
    get :edit,{:id=>@play_list.id.to_s}    
    assert @response.success?,'登录的用户可以编辑播放列表，但是只能编辑自己的'
    @play_list.ua(:user_id,User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id)
    get :edit,{:id=>@play_list.id.to_s}
    assert assert 401==@response.status,'登录的用户可以编辑播放列表，但是只能编辑自己的'
  end
    
  it "播放列表销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@play_list.id.to_s}
    assert 302==@response.status
  end
  it "播放列表销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    @play_list.ua(:user_id,@user.id)
    delete :destroy,{:id=>@play_list.id.to_s}
    assert (302==@response.status and URI(@response.location).path == "/mine/view_all_playlists"),'登录的用户可以删除播放列表，但是只能编辑自己的'
    @play_list.ua(:user_id,User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id)
    delete :destroy,{:id=>@play_list.id.to_s}
    assert assert 401==@response.status,'登录的用户可以删除播放列表，但是只能编辑自己的'
  end

  it "播放列表的创建和修改处理器：handler - 游客状态" do
    assert @controller.current_user.nil?
    post :handler,{"encrypted_playlist_id"=>"4acf2fcdacda8a832f6fe56da12f14b1", "form_hash"=>"118b48a2", "title"=>"dfsdfsad23113321321321", "description"=>"321132321213312132", "is_private"=>"0", "allow_embedding"=>"1", "allow_ratings"=>"1", "action"=>"handler", "controller"=>"play_lists", "id"=>"50ac7eb1e13823a446000051"}  
    assert (302==@response.status and URI(@response.location).path == "/")
  end
  it "播放列表的创建和修改处理器：handler" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    @play_list.ua(:user_id,@user.id)
    params = {"form_hash"=>'blah-blah', "title"=>"213321123123312312132", "playlist_kejian_deleted"=>["0", "0"], "playlist_kejian_id"=>["5068717de13823350b001378", "50a72631e13823576200005f"], "playlist_video_annotation"=>["", "dfdfasfdafdasdfsafdasfdsafdadfsadfasdfsadfsafdasdsafdas"], "playlist_thumbnail_video_id"=>"50a72631e13823576200005f", "description"=>"231312312132321312123321", "is_private"=>"0", "allow_embedding"=>"1", "allow_ratings"=>"1", "action"=>"handler", "controller"=>"play_lists", 'id'=>  @play_list.id.to_s}.with_indifferent_access  
    params[:encrypted_playlist_id] = Digest::MD5.hexdigest(params[:id]+'.liber.'+Digest::MD5.hexdigest(params[:form_hash]))
    post :handler,params
    assert  (302==@response.status and URI(@response.location).path == "/play_lists/"+@play_list.id.to_s),'登录后，创建和修改处理器可以成功，但是必须是作用在自己的playlist上'
    @play_list.ua(:user_id,User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id)
    post :handler,params
    assert (401==@response.status and URI(@response.location).path == "/"),'登录后，创建和修改处理器可以成功，但是必须是作用在自己的playlist上'
  end

    
end