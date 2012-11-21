# -*- encoding : utf-8 -*-
require "test_helper"

describe CoursewaresController do
  before do
    @cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "new - 游客状态" do
    assert @controller.current_user.nil?
    get :new
    assert 302==@response.status,'课件冒烟C1 - 游客状态：游客【不能】进入上传课件页面，跳转到登陆页面'
  end
  it "new" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :new
    assert @response.success?,'课件冒烟C1：登录用户可以进入上传课件页面'
  end
  it "show - 游客状态" do
    assert @controller.current_user.nil?
    get :show,:id=>@cw.id
    assert @response.success?,'课件冒烟R1 - 游客状态：游客可以查看任一普通课件'
  end
  it "show" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:id=>@cw.id
    assert @response.success?,'课件冒烟R1：登录用户可以查看任意普通课件'
  end
  it 'embed - 游客状态' do
    assert @controller.current_user.nil?
    get :embed,:id=>@cw.id
    assert @response.success?,'课件冒烟R2 - 游客状态：游客可以嵌入任一普通课件'
  end
  it 'embed' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :embed,:id=>@cw.id
    assert @response.success?,'课件冒烟R2：登录用户可以嵌入任一普通课件'
  end
  it 'edit - 游客状态' do
    assert @controller.current_user.nil?
    get :edit,:id=>@cw.id
    assert 302==@response.status,'课件冒烟U1 - 游客状态：游客【不能】编辑课件，跳转到登陆页'
  end
  it 'edit' do
    @cw.update_attribute(:uploader_id,@user.id)
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,:id=>@cw.id
    assert @response.success?,'课件冒烟U1：自己可以编辑自己的课件'
    dengchu!
    @user = User.where(:id.ne=>@user.id,:email.nin=>Setting.admin_emails).first
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :edit,:id=>@cw.id
    assert 401==@response.status,'课件冒烟U1：别人非管理员【不能】编辑他人的课件'
  end
  it "ktvid_slide_pic - 游客状态" do
    assert @controller.current_user.nil?
    get :ktvid_slide_pic,:id => 'whatever'
    assert 302==@response.status && @response.location.ends_with?('/mqdefault.jpg'),'游客访问课件图片可以得到默认图片'
    get :ktvid_slide_pic,:id => @cw.id.to_s,:pic=>'thumb_slide_0.jpg'
    assert 301==@response.status && !@response.location.ends_with?('thumb_slide_0.jpg'),'游客访问课件图片可以得到正常图片'
  end
  it "ktvid_slide_pic" do
    denglu! @user
    assert @controller.current_user.id==@user.id    
    get :ktvid_slide_pic,:id => 'whatever'
    assert 302==@response.status && @response.location.ends_with?('/mqdefault.jpg'),'注册用户访问课件图片可以得到默认图片'
    get :ktvid_slide_pic,:id => @cw.id.to_s,:pic=>'thumb_slide_0.jpg'
    assert 301==@response.status && @response.location.ends_with?('thumb_slide_0.jpg'),'注册用户访问课件图片可以得到正常图片'
  end

  it "sum_cw_views_count" do
    denglu! @user
    assert @controller.current_user.id==@user.id
    user_sum_cw_views_count = @user.sum_cw_views_count
    get :show,:id=>@cw.id
    @user.reload
    assert user_sum_cw_views_count + 1 == @user.sum_cw_views_count,'用户看了课件，那么他的sum_cw_views_count应该+1'    
  end

end
