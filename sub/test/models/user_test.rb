# -*- encoding : utf-8 -*-
require "test_helper"
describe User do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
    @user1.following_count = 0
    @user2.following_count = 0
    @user1.follower_count = 0
    @user2.follower_count = 0
    @user1.follower_ids = 0
    @user2.follower_ids = 0
    @user1.following_ids = 0
    @user2.following_ids = 0
    @user1.save(:validate=>false)
    @user2.save(:validate=>false)
    @user1.reload
    @user2.reload
  end
  it "followers_n_following" do
    @user1.following_ids=[]
    @user2.following_ids=[]
    @user1.follower_ids=[]
    @user2.follower_ids=[]
    @user1.save(:validate=>false)
    @user2.save(:validate=>false)
    @user1.reload
    @user2.reload
    u1_followers_count_before = @user1.followers_count
    u2_followers_count_before = @user2.followers_count
    u1_following_count_before = @user1.following_count
    u2_following_count_before = @user2.following_count
    @user1.follow(@user2)
    @user1.reload
    @user2.reload
    assert u1_following_count_before + 1 == @user1.following_count,'A关注B,A关注数+1'
    assert u2_followers_count_before + 1 == @user2.followers_count,'A关注B,B被关注数+1'
    assert @user1.followed?(@user2),'A关注B,A记录了B的关注行为'
    assert @user2.followed_by?(@user1),'A关注B,B记录了A的关注行为'
    @user1.unfollow(@user2)
    @user1.reload
    @user2.reload
    assert u1_following_count_before == @user1.following_count,'A取消关注B,A关注数恢复'
    assert u2_followers_count_before == @user2.followers_count,'A取消关注B,B被关注数恢复'
    refute @user1.followed?(@user2),'A取消关注B,A取消了B的关注行为'
    refute @user2.followed_by?(@user1),'A取消关注B,A取消了B的关注行为'
  end
  it "follow_n_unfollowing department" do
    @department = Department.first
    @user1.followed_department_fids=[]
    @department.follower_ids = []
    @user1.save(:validate=>false)
    @department.save(:validate=>false)
    @user1.reload
    @department.reload
    department_followers_count = @department.followers_count
    # !!!
    @user1.follow_department(@department)
    # !!!
    @user1.reload
    @department.reload
    assert @user1.department_followed?(@department),'成功关注学院'
    assert department_followers_count+1 == @department.followers_count,'学院的关注数字加1'
    # !!!
    @user1.unfollow_department(@department)
    # !!!
    @user1.reload
    @department.reload
    refute @user1.department_followed?(@department),'成功取消关注学院'
    assert department_followers_count == @department.followers_count,'学院的关注数字恢复'
  end
  
end
