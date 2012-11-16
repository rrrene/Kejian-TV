require "minitest_helper"
class CommentTest < MiniTest::Unit::TestCase
  def setup
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  def test_after_create_comments_count
    @courseware1 = Courseware.nondeleted.normal.is_father.first
    user1_comments_count = @user1.comments_count
    courseware1_comments_count = @courseware1.comments_count
    c = Comment.new
    c.user_id = @user1.id
    c.commentable_id = @courseware1.id
    c.commentable_type = 'Courseware'
    c.save(:validate=>false)
    @user1.reload
    @courseware1.reload
    assert user1_comments_count + 1 == @user1.comments_count,'用户评论后用户的评论数字应该+1'
    assert courseware1_comments_count + 1 == @courseware1.comments_count,'用户名评论后被评论的课件的评论数字应+1'
  end
end