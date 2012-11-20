# -*- encoding : utf-8 -*-
require "test_helper"
describe WelcomeController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end
  it 'index - 游客状态' do
    assert @controller.current_user.nil?
    get :index
    assert 302==@response.status && @response.location.ends_with?('/welcome/latest'),'welcome#index冒烟：游客看首页时无条件跳转到所有课件'
  end
  it 'index' do
    denglu! @user
    assert @controller.current_user.id==@user.id
    get :index
    assert 302==@response.status && @response.location.ends_with?('/welcome/latest'),'welcome#index冒烟：登录用户看首页时无条件跳转到所有课件'
  end
end