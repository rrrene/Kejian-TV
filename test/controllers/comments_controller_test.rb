# -*- encoding : utf-8 -*-
require "test_helper"
describe CommentsController do
  before do
    @comment = Comment.nondeleted.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "评论创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 401==@response.status
  end
  it "评论创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create,{"comment"=>{"commentable_type"=>"Courseware", "commentable_id"=>Courseware.non_redirect.nondeleted.normal.is_father.first.id.to_s, "body"=>"dsafdsfafdsadfsafdsadsfadfas"}}
    assert @response.success?
  end
  
  it "评论创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status
  end
  it "评论创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert 405==@response.status
  end
    
  it "评论读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index,{"type"=>"Courseware", "id"=>Courseware.non_redirect.nondeleted.normal.is_father.first.id.to_s}
    assert @response.success?
  end
  it "评论读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index,{"type"=>"Courseware", "id"=>Courseware.non_redirect.nondeleted.normal.is_father.first.id.to_s}
    assert @response.success?
  end
    
  it "评论读取R1: show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,{:id=>@comment.id.to_s}
    assert 405==@response.status
  end
  it "评论读取R1: show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,{:id=>@comment.id.to_s}
    assert 405==@response.status
  end
    
  it "评论更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@comment.id.to_s}
    assert 302==@response.status
  end
  it "评论更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@comment.id.to_s}
    assert 405==@response.status
  end
    
  it "评论更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@comment.id.to_s}
    assert 302==@response.status
  end
  it "评论更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,{:id=>@comment.id.to_s}
    assert 405==@response.status
  end
    
  it "评论销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@comment.id.to_s}
    assert 302==@response.status
  end
  it "评论销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    delete :destroy,{:id=>@comment.id.to_s}
    assert 405==@response.status
  end

end
