# -*- encoding : utf-8 -*-
require "minitest_helper"
class CoursewareIntegrationTest < IntegrationTest
  def setup
    @cw=Courseware.nondeleted.normal.is_father.first
  end
  def test_smoking
    visit "/coursewares/#{@cw.id}"
    assert page.text.include? @cw.title
  end
  def test_sum_cw_views_count
    denglu! @user1
    user1_sum_cw_views_count = @user1.sum_cw_views_count
    visit "/coursewares/#{@cw.id}"
    @user1.reload
    assert user1_sum_cw_views_count + 1 == @user1.sum_cw_views_count
  end
end