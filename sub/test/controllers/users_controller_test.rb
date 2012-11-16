# -*- encoding : utf-8 -*-
require "test_helper"
describe UsersController do
  before do
    @user=User.nondeleted.first
  end
  it "profile_view_count+1" do
    user_profile_view_count = @user.profile_view_count
    get :show,:id => @user.id
    @user.reload
    assert user_profile_view_count + 1 == @user.profile_view_count,'用户的profile页被人看了，应该profile_view_count+1'
  end
end