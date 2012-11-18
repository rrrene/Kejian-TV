# -*- encoding : utf-8 -*-
require "test_helper"
describe PlayListsController do
  before do
    @play_list=PlayList.no_privacy.destroyable.normal.first
  end
  it "views_count+1" do
    views_count = @play_list.views_count
    get :show,:id => @play_list.id
    @play_list.reload
    assert views_count + 1 == @play_list.views_count,'play list被人看了，应该views_count+1'
  end
end