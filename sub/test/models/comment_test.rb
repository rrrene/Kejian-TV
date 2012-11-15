require "minitest_helper"
class CommentTest < MiniTest::Unit::TestCase
  def setup
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  def after_create_user_comments_count
    user1_comments_count = @user1.comments_count
    c = Comment.new
    c.user_id = @user1.id
    c.save(:validate=>false)
    @user1.reload
    assert user1_comments_count + 1 == @user1.comments_count
  end
  def after_create_courseware_comments_count
    @courseware1 = Courseware.nondeleted.normal.is_father.first
    courseware1_comments_count = @courseware1.comments_count
    c = Comment.new
    c.courseware_id = @courseware1.id
    c.save(:validate=>false)
    @courseware1.reload
    assert courseware1_comments_count + 1 == @courseware1.comments_count
  end
end