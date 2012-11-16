# -*- encoding : utf-8 -*-
require "test_helper"

describe CoursewaresController do
  before do
    @cw=Courseware.nondeleted.normal.is_father.first
    @user=User.nondeleted.first    
  end
  it "smokes" do
    get :show,:id=>@cw.id
    assert @response.success?,'课件冒烟，课件应该能show'    
  end
  it "sum_cw_views_count okay" do
    denglu! @user
    user_sum_cw_views_count = @user.sum_cw_views_count
    get :show,:id=>@cw.id
    @user.reload
    assert user_sum_cw_views_count + 1 == @user.sum_cw_views_count,'用户看了课件，那么他的sum_cw_views_count应该+1'    
  end
end
