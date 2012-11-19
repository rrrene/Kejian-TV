# -*- encoding : utf-8 -*-
require "test_helper"

describe CoursewaresController do
  before do
    @cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    @user=User.nondeleted.first
  end
  it "new - 游客状态" do
    get :new
    assert 302==@response.status,'课件冒烟C1 - 游客状态'
  end
  it "new" do
    denglu! @user
    get :new
    assert @response.success?,'课件冒烟C1'
  end
  it "show - 游客状态" do
    get :show,:id=>@cw.id
    assert @response.success?,'课件冒烟R1 - 游客状态'
  end
  it "show" do
    get :show,:id=>@cw.id
    assert @response.success?,'课件冒烟R1'
  end
  it 'embed - 游客状态' do
    get :embed,:id=>@cw.id
    assert @response.success?,'课件冒烟R2 - 游客状态'
  end
  it 'embed' do
    get :embed,:id=>@cw.id
    assert @response.success?,'课件冒烟R2'
  end
  it 'edit - 游客状态' do
    get :edit,:id=>@cw.id
    assert 302==@response.status,'课件冒烟U1 - 游客状态'
  end
  it 'edit' do
    @cw.update_attribute(:uploader_id,@user.id)
    denglu! @user
    get :edit,:id=>@cw.id
    assert @response.success?,'课件冒烟U1'
  end
  it "sum_cw_views_count" do
    denglu! @user
    user_sum_cw_views_count = @user.sum_cw_views_count
    get :show,:id=>@cw.id
    @user.reload
    assert user_sum_cw_views_count + 1 == @user.sum_cw_views_count,'用户看了课件，那么他的sum_cw_views_count应该+1'    
  end

end
