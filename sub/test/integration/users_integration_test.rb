# -*- encoding : utf-8 -*-
require "minitest_helper"
class UserIntegrationTest < IntegrationTest
  def test_profile_view_count
    item=User.nondeleted.first
    item_profile_view_count = item.profile_view_count
    visit "/users/#{item.id}"
    item.reload
    assert item_profile_view_count + 1 == item.profile_view_count
  end
end
