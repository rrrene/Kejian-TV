# -*- encoding : utf-8 -*-
require "test_helper"

describe CoursewaresController do
  before do
    @cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it "课件创建C0: create - 游客状态" do
    assert @controller.current_user.nil?
    post :create
    assert 302==@response.status
  end
  it "课件创建C0: create" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    post :create
    assert 405==@response.status
  end
  
  it "课件创建C1: new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status,'游客【不能】进入上传课件页面，跳转到登陆页面'
  end
  it "课件创建C1: new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert @response.success?,'登录用户可以进入上传课件页面'
  end
    
  it "课件读取R0: index - 游客状态" do
    assert @controller.current_user.nil?
    get :index
    assert @response.success?
  end
  it "课件读取R0: index" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert @response.success?
  end

  it "课件读取R1: show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,{:id=>@cw.id.to_s}
    assert @response.success?,'游客可以查看任一普通课件'
  end
  it "课件读取R1: show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    user_sum_cw_views_count = @user.sum_cw_views_count
    get :show,{:id=>@cw.id.to_s}
    assert @response.success?,'登录用户可以查看任意普通课件'
    @user.reload
    assert user_sum_cw_views_count + 1 == @user.sum_cw_views_count,'用户看了课件，那么他的sum_cw_views_count应该+1'    
  end
  it '课件读取R2: embed - 游客状态' do
    assert @controller.current_user.nil?
    get :embed,:id=>@cw.id
    assert @response.success?,'游客状态：游客可以嵌入任一普通课件'
  end
  it '课件读取R2: embed' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :embed,:id=>@cw.id
    assert @response.success?,'登录用户可以嵌入任一普通课件'
  end
    
  it "课件更新R0: update - 游客状态" do
    assert @controller.current_user.nil?
    put :update,{:id=>@cw.id.to_s}
    assert 302==@response.status
  end
  it "课件更新R0: update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    put :update,{:id=>@cw.id.to_s}
    assert 405==@response.status
  end
    
  it "课件更新R1: edit - 游客状态" do
    assert @controller.current_user.nil?
    get :edit,{:id=>@cw.id.to_s}
    assert 302==@response.status
  end
  it "课件更新R1: edit" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    @cw.update_attribute(:uploader_id,@user.id)
    get :edit,:id=>@cw.id.to_s
    assert @response.success?,'自己可以编辑自己的课件'
    dengchu!
    @user = User.where(:id.ne=>@user.id,:email.nin=>Setting.admin_emails).first
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,:id=>@cw.id.to_s
    assert 401==@response.status,'非管理员【不能】编辑他人的课件'
  end
    
  it "课件销毁D: destroy - 游客状态" do
    assert @controller.current_user.nil?
    delete :destroy,{:id=>@cw.id.to_s}
    assert 302==@response.status
  end
  it "课件销毁D: destroy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    @cw.ua(:uploader_id,@user.id)
    delete :destroy,{:id=>@cw.id.to_s}
    assert 302==@response.status,'用户可以删除自己的课件，删除后跳转，但是别人的课件不能删除'
    @cw.ua(:uploader_id,User.nondeleted.normal.where(:email.nin=>Setting.admin_emails,:id.ne=>@user.id).first.id)
    delete :destroy,{:id=>@cw.id.to_s}
    assert 401==@response.status,'用户可以删除自己的课件，删除后跳转，但是别人的课件不能删除'
  end
  it "得到课件的某些图片ktvid_slide_pic - 游客状态" do
    assert @controller.current_user.nil?
    get :ktvid_slide_pic,:id => 'whatever'
    assert 302==@response.status && @response.location.ends_with?('/mqdefault.jpg'),'游客访问课件图片可以得到默认图片'
    get :ktvid_slide_pic,:id => @cw.id.to_s,:pic=>'thumb_slide_0.jpg'
    assert 301==@response.status && !@response.location.ends_with?('thumb_slide_0.jpg'),'游客访问课件图片可以得到正常图片'
  end
  it "得到课件的某些图片ktvid_slide_pic" do
    denglu! @user
    assert @controller.current_user.id==@user.id    
    get :ktvid_slide_pic,:id => 'whatever'
    assert 302==@response.status && @response.location.ends_with?('/mqdefault.jpg'),'注册用户访问课件图片可以得到默认图片'
    get :ktvid_slide_pic,:id => @cw.id.to_s,:pic=>'thumb_slide_0.jpg'
    assert 301==@response.status && @response.location.ends_with?('thumb_slide_0.jpg'),'注册用户访问课件图片可以得到正常图片'
  end   

  it "我的课件瀑布mine - 游客状态" do
    assert @controller.current_user.nil?
    get :mine
    assert 302==@response.status
  end
  it "我的课件瀑布mine" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :mine
    assert @response.success?
  end

  it "最新课件瀑布latest - 游客状态" do
    assert @controller.current_user.nil?
    get :latest
    assert @response.success?
  end
  it "最新课件瀑布latest" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :latest
    assert @response.success?
  end

  it "最热课件瀑布latest - 游客状态" do
    assert @controller.current_user.nil?
    get :latest
    assert @response.success?
  end
  it "最热课件瀑布latest" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :latest
    assert @response.success?
  end


  it "下载课件清单页面download - 游客状态" do
    assert @controller.current_user.nil?
    flunk "p.s.v.r 会很快来做这个功能"
  end
  it "下载课件清单页面download" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    flunk "p.s.v.r 会很快来做这个功能"    
  end

  it "下载课件提交download - 游客状态" do
    assert @controller.current_user.nil?
    flunk "p.s.v.r 会很快来做这个功能"
  end
  it "下载课件提交download" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    flunk "p.s.v.r 会很快来做这个功能"
  end



end
