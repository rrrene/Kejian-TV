# -*- encoding : utf-8 -*-
require "test_helper"
describe PlayListsController do
  before do
    @play_list=PlayList.no_privacy.destroyable.normal.first
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it "views_count+1 - 游客状态" do
    views_count = @play_list.views_count
    assert @controller.current_user.nil?
    get :show,:id => @play_list.id

    assert @response.success?,'播放列表冒烟R1 - 游客状态：游客能看普通播放列表'
    @play_list.reload
    assert views_count + 1 == @play_list.views_count,'播放列表冒烟R1 - 游客状态：普通播放列表被游客看了，应该views_count+1'
  end
  it "views_count+1" do
    views_count = @play_list.views_count
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :show,:id => @play_list.id
    assert @response.success?,'播放列表冒烟R1 - 登录用户能看普通播放列表'
    @play_list.reload
    assert views_count + 1 == @play_list.views_count,'播放列表冒烟R1 - 普通播放列表被登录用户看了，应该views_count+1'
  end
end