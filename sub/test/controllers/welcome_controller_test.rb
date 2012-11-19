# -*- encoding : utf-8 -*-
require "test_helper"
describe WelcomeController do
  before do
    @user=User.nondeleted.first
  end
  it 'index' do
    get :index
    assert 302==@response.status,'welcome#index冒烟 - 游客状态'
  end
  it 'index' do
    denglu! @user
    get :index
    assert 302==@response.status,'welcome#index冒烟'
  end
  
end