require "minitest_helper"
class UserTest < MiniTest::Unit::TestCase
  def setup
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  def test_followers_n_following
    u1_followers_count_before = @user1.followers_count
    u2_followers_count_before = @user2.followers_count
    u1_following_count_before = @user1.following_count
    u2_following_count_before = @user2.following_count  
    @user1.follow(@user2)
    @user1.reload
    @user2.reload
    assert u1_following_count_before + 1 == @user1.following_count
    assert u2_followers_count_before + 1 == @user2.followers_count
    assert @user1.followed?(@user2)
    assert @user2.followed_by?(@user1)
    @user1.unfollow(@user2)
    @user1.reload
    @user2.reload
    assert u1_following_count_before == @user1.following_count
    assert u2_followers_count_before == @user2.followers_count
    refute @user1.followed?(@user2)
    refute @user2.followed_by?(@user1)
  end
  def test_thank_courseware
    @courseware = Courseware.nondeleted.normal.is_father.where(:uploader_id=>@user2.id).first
    user1_thank_coursewares_count = @user1.thank_coursewares_count
    user2_thanked_coursewares_count = @user2.thanked_coursewares_count
    courseware_thanked_count = @courseware.thanked_count
    courseware_disliked_count = @courseware.disliked_count
    @user1.thank_courseware(@courseware)
    @user1.reload
    @user2.reload
    @courseware.reload
    assert user1_thank_coursewares_count + 1 == @user1.user1_thank_coursewares_count
    assert user2_thanked_coursewares_count + 1 == @user2.user2_thanked_coursewares_count
    assert courseware_thanked_count + 1 == @courseware.thanked_count
    assert courseware_disliked_count == @courseware.disliked_count
    assert @courseware.thanked_user_ids.include?(@user1)
    refute @courseware.disliked_user_ids.include?(@user1)
  end
end
