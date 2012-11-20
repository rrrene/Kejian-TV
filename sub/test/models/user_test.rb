# -*- encoding : utf-8 -*-
require "test_helper"
describe User do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "用户关注用户" do
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
  it "用户关注院系" do
    @department = Department.nondeleted.gotfid.first
    @user1.followed_department_fids=[]
    @department.follower_ids = []
    @department.followers_count = 0
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
  it "用户关注课程" do
    @course = Course.nondeleted.gotfid.first
    @user1.followed_course_fids=[]
    @course.follower_ids = []
    @course.followers_count = 0
    @user1.save(:validate=>false)
    @course.save(:validate=>false)
    @user1.reload
    @course.reload
    course_followers_count = @course.followers_count
    # !!!
    @user1.follow_course(@course)
    # !!!
    @user1.reload
    @course.reload
    assert @user1.course_followed?(@course),'成功关注课程'
    assert course_followers_count+1 == @course.followers_count,'课程的关注数字加1'
    # !!!
    @user1.unfollow_course(@course)
    # !!!
    @user1.reload
    @course.reload
    refute @user1.course_followed?(@course),'成功取消关注课程'
    assert course_followers_count == @course.followers_count,'课程的关注数字恢复'
  end
  it "初次创建后，为用户创建三个默认的播放列表" do
    u = User.new
    u.save(:validate=>false)
    pl1 = PlayList.nondeleted.where(:user_id => u.id,:undestroyable=>true).collect(&:title)
    assert pl1.include?('收藏'),'初次创建后，为用户创建"收藏"播放列表'
    assert pl1.include?('稍后阅读'),'初次创建后，为用户创建"稍后阅读"播放列表'
    assert pl1.include?('历史记录'),'初次创建后，为用户创建"历史记录"播放列表'
  end
  it '软删除之前判断是否有课件或播放列表依赖于这个用户' do
    cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    pl=PlayList.no_privacy.destroyable.normal.first
    u = User.new
    u.save(:validate=>false)
    ret = u.instance_eval(&User.before_soft_delete)
    refute false==ret,'没有任何课件或除三个默认的播放列表之外的其他播放列表依赖，可以进行删除'
    cw_backup = cw.uploader_id
    cw.uploader_id = u.id
    cw.save(:validate=>false)
    u.reload
    ret = u.instance_eval(&User.before_soft_delete)
    assert false==ret,'增加了课件依赖，不能进行删除'
    cw.uploader_id = cw_backup
    cw.save(:validate=>false)
    pl_backup = pl.user_id
    pl.user_id = u.id
    pl.save(:validate=>false)
    u.reload
    ret = u.instance_eval(&User.before_soft_delete)
    assert false==ret,'增加了除三个默认的播放列表之外的其他播放列表依赖，不能进行删除'
    pl.user_id = pl_backup
    pl.save(:validate=>false)
    u.reload
    ret = u.instance_eval(&User.before_soft_delete)
    refute false==ret,'解除课件和除三个默认的播放列表之外的其他播放列表依赖，可以进行删除'
  end
  it "异步清理" do
    dpt1 = Department.nondeleted[0]
    dpt2 = Department.nondeleted[1]
    c1 = Course.nondeleted.gotfid[0]
    c2 = Course.nondeleted.gotfid[1]
    cw1 = Courseware.non_redirect.nondeleted.normal.is_father[0]
    cw2 = Courseware.non_redirect.nondeleted.normal.is_father[1]
    cmt1 = Comment.nondeleted[0]
    cmt2 = Comment.nondeleted[1]
    pl1 = PlayList.no_privacy.destroyable.normal[0]
    pl2 = PlayList.no_privacy.destroyable.normal[1]
    crazy_user = User.new
    crazy_user.save(:validate=>false)
    pl_default_1 = PlayList.locate(crazy_user.id,'收藏')
    pl_default_2 = PlayList.locate(crazy_user.id,'稍后阅读')
    pl_default_3 = PlayList.locate(crazy_user.id,'历史记录')
    success_crazy_cm1,crazy_cm1 = Comment.real_create({:comment => {"commentable_type"=>"Courseware","commentable_id"=>cw1.id.to_s,"body"=>"#{Time.now.to_i}#{rand.to_s}"}}.with_indifferent_access,crazy_user)
    success_crazy_cm2,crazy_cm2 = Comment.real_create({:comment => {"commentable_type"=>cmt1.commentable_type,"commentable_id"=>cmt1.commentable_id,"body"=>"#{Time.now.to_i}#{rand.to_s}",'replied_to_comment_id'=>cmt1.id.to_s}}.with_indifferent_access,crazy_user)
    assert success_crazy_cm1
    assert success_crazy_cm2
    crazy_user.follow(@user1)
    crazy_user.follow(@user2)
    crazy_user.follow_department(dpt1)
    crazy_user.follow_department(dpt2)
    crazy_user.follow_course(c1)
    crazy_user.follow_course(c2)
    cmt1.disliked_by_user(crazy_user)
    crazy_user.like_comment(cmt2)
    cw1.disliked_by_user(crazy_user)
    crazy_user.thank_courseware(cw2)
    pl1.disliked_by_user(crazy_user)
    crazy_user.like_playlist(pl2)
    # 1. 预检--------------    
    crazy_user.reload
    @user1.reload
    @user2.reload
    dpt1.reload
    dpt2.reload
    c1.reload
    c2.reload    
    pl_default_1.reload
    pl_default_2.reload
    pl_default_3.reload
    crazy_cm1.reload
    crazy_cm2.reload
    cmt1.reload
    cmt2.reload
    cw1.reload
    cw2.reload
    pl1.reload
    pl2.reload
    d1 = @user1.followers_count
    d2 = @user1.followers_count
    d3 = dpt1.followers_count
    d4 = dpt2.followers_count
    d5 = c1.followers_count
    d6 = c2.followers_count
    d7 = cmt1.votedown
    d8 = cmt2.voteup
    d9 = cw1.disliked_count
    d10 = cw2.thanked_count
    d11 = pl1.vote_down
    d12 = pl2.vote_up
    # 2. 清理！！！--------------    
    crazy_user.asynchronously_clean_me
    # 3. 重检--------------
    crazy_user.reload
    @user1.reload
    @user2.reload
    dpt1.reload
    dpt2.reload
    c1.reload
    c2.reload    
    pl_default_1.reload
    pl_default_2.reload
    pl_default_3.reload
    crazy_cm1.reload
    crazy_cm2.reload
    cmt1.reload
    cmt2.reload
    cw1.reload
    cw2.reload
    pl1.reload
    pl2.reload
    assert pl_default_1.soft_deleted?,'删除【传播】到了用户的三个默认的播放列表'
    assert pl_default_2.soft_deleted?,'删除【传播】到了用户的三个默认的播放列表'
    assert pl_default_3.soft_deleted?,'删除【传播】到了用户的三个默认的播放列表'
    assert crazy_cm1.soft_deleted?,'删除【传播】到了用户发表过的评论'
    assert crazy_cm2.soft_deleted?,'删除【传播】到了用户发表过的评论'
    refute @user1.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'
    refute @user2.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'
    refute dpt1.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'
    refute dpt2.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'
    refute c1.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'
    refute c2.follower_ids.include?(crazy_user.id),'清洗关注型脏引用'    
    refute cmt1.votedown_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    refute cmt2.voteup_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    refute cw1.disliked_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    refute cw2.thanked_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    refute pl1.disliked_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    refute pl2.liked_user_ids.include?(crazy_user.id),'清洗投票型脏引用'    
    assert d1 - 1 == @user1.followers_count,'关注型计数还原'
    assert d2 - 1 == @user1.followers_count,'关注型计数还原'
    assert d3 - 1 == dpt1.followers_count,'关注型计数还原'
    assert d4 - 1 == dpt2.followers_count,'关注型计数还原'
    assert d5 - 1 == c1.followers_count,'关注型计数还原'
    assert d6 - 1 == c2.followers_count,'关注型计数还原'
    assert d7 - 1 == cmt1.votedown,'投票型计数还原'
    assert d8 - 1 == cmt2.voteup,'投票型计数还原'
    assert d9 - 1 == cw1.disliked_count,'投票型计数还原'
    assert d10 - 1 == cw2.thanked_count,'投票型计数还原'
    assert d11 - 1 == pl1.vote_down,'投票型计数还原'
    assert d12 - 1 == pl2.vote_up,'投票型计数还原'
    refute @user1.soft_deleted?,'无辜的资源不能删'
    refute @user2.soft_deleted?,'无辜的资源不能删'
    refute dpt1.soft_deleted?,'无辜的资源不能删'
    refute dpt2.soft_deleted?,'无辜的资源不能删'
    refute c1.soft_deleted?,'无辜的资源不能删'
    refute c2.soft_deleted?,'无辜的资源不能删'    
    refute cmt1.soft_deleted?,'无辜的资源不能删'
    refute cmt2.soft_deleted?,'无辜的资源不能删'
    refute cw1.soft_deleted?,'无辜的资源不能删'
    refute cw2.soft_deleted?,'无辜的资源不能删'
    refute pl1.soft_deleted?,'无辜的资源不能删'
    refute pl2.soft_deleted?,'无辜的资源不能删'
  end
  it "禁用户" do
    # todo
  end
  
end

