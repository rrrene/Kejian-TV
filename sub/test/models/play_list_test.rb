# -*- encoding : utf-8 -*-
require 'test_helper'
describe PlayList do
  before do 
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "用一个名字定位一个播放列表" do
    name = "PL#{Time.now.to_i}#{rand}"
    assert PlayList.where(:title => name).first.nil?,"为了测试，这个名字肯定不存在"
    play_list = PlayList.locate(@user1.id,name)
    assert play_list.persisted?,"如果没有这个名字的播放列表，定位后就有了"
  end
  it "添加课件" do
    cw1 = Courseware.new;cw1.save(:validate=>false)
    cw2 = Courseware.new;cw2.save(:validate=>false)
    cw3 = Courseware.new;cw3.save(:validate=>false)
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    play_list.add_one_thing(cw1.id)
    play_list.add_one_thing(cw2.id)
    play_list.add_one_thing(cw3.id,true)
    play_list.reload
    assert play_list.content.index(cw1.id) < play_list.content.index(cw2.id),'成功放入课件，先来后到'
    assert 0==play_list.content.index(cw3.id),'成功在头部放入课件'
  end
  it "播放列表的状态正常 当且仅当 它所包含的所有课件状态正常" do
    user_n = User.new
    user_n.save(:validate=>false)
    cw1 = Courseware.new
    cw1.status=1
    cw1.uploader_id = user_n.id
    cw1.save(:validate=>false)
    cw2 = Courseware.new
    cw2.uploader_id = user_n.id
    cw2.status=2
    cw2.save(:validate=>false)
    cw3 = Courseware.new
    cw3.uploader_id = user_n.id
    cw3.status=0
    cw3.save(:validate=>false)
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    play_list.add_one_thing(cw1.id)
    play_list.add_one_thing(cw2.id)
    play_list.add_one_thing(cw3.id)
    play_list.set_status
    play_list.reload
    refute 0==play_list.status,'cw1和cw2未达到正常状态，所以在执行了set_status之后play_list也不正常'
    cw1.status=0
    cw1.save(:validate=>false)
    cw2.status=0
    cw2.save(:validate=>false)
    play_list.set_status
    play_list.reload
    assert 0==play_list.status,'cw1和cw2达到了正常状态，所以在执行了set_status之后play_list也正常了'    
  end
  it "播放列表的course_fids的计算" do
    cw1 = Courseware.first
    cw2 = Courseware.where(:course_fid.ne=>cw1.course_fid).first
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    play_list.add_one_thing(cw1.id)
    assert 1==play_list.course_fids.count(cw1.course_fid),'加一个课件有一个课件的课程fid'
    play_list.add_one_thing(cw2.id)
    assert 1==play_list.course_fids.count(cw2.course_fid),'加一个课件就有一个课件的课程fid'
    play_list.content.delete(cw2.id)
    assert 0==play_list.course_fids.count(cw2.course_fid),'没了cw2就没了cw2.course_fids'
  end
  it "播放列表的
 oooO ↘┏━┓ ↙ Oooo 
 ( 踩)→┃顶┃ ←(踩 ) 
  \ ( →┃√┃ ← ) / 
　 \_)↗┗━┛ ↖(_/ 
" do
    @play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    @play_list.liked_user_ids = []
    @play_list.disliked_user_ids = []
    @user1.thanked_play_list_ids = []
    @user2.thanked_play_list_ids = []

    @user1.dislike_play_lists_count = 0
    @user1.like_play_lists_count = 0
    @user1.disliked_play_lists_count = 0
    @user1.liked_play_lists_count = 0

    @user2.dislike_play_lists_count = 0
    @user2.like_play_lists_count = 0
    @user2.disliked_play_lists_count = 0
    @user2.liked_play_lists_count = 0

    @user1.save(:validate=>false)
    @user2.save(:validate=>false)

    @user1.reload
    @user2.reload

    @play_list_user2 = PlayList.locate(@user2.id,"PL#{Time.now.to_i}#{rand}")
    @play_list_user2.liked_user_ids = []
    @play_list_user2.disliked_user_ids = []
    @play_list_user2.vote_up=0
    @play_list_user2.vote_down=0
    @play_list_user2.save(:validate=>false)
    @play_list_user2.reload
    user1_dislike_play_lists_count = @user1.dislike_play_lists_count
    user2_disliked_play_lists_count = @user2.disliked_play_lists_count
    user1_like_play_lists_count = @user1.like_play_lists_count
    user2_liked_play_lists_count = @user2.liked_play_lists_count
    play_list_liked_play_lists_count = @play_list_user2.vote_up
    play_list_disliked_count = @play_list_user2.vote_down
    ## 被不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_play_lists_count + 1 == @user1.disliked_play_lists_count,'不喜欢这个播放列表的用户的不喜欢表达总次数+1'
    assert user2_disliked_play_lists_count + 1 == @user2.dislike_play_lists_count,'被不喜欢这个播放列表的用户的被不喜欢总次数+1'
    assert play_list_liked_play_lists_count == @play_list_user2.vote_up,'被不喜欢后，播放列表的喜欢次数保持不变'  
    assert play_list_disliked_count + 1 == @play_list_user2.vote_down,'被不喜欢后，播放列表的不喜欢次数+1'
    assert @play_list_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的不喜欢人记录了不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ## 不喜欢后，被喜欢
    @user1.thank_play_list(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_like_play_lists_count + 1 == @user1.liked_play_lists_count,'之后，这个人又突然喜欢了这个播放列表，那么这个人的喜欢表达次数+1'
    assert user2_liked_play_lists_count + 1 == @user2.like_play_lists_count,'被喜欢这个播放列表的被喜欢次数+1'
    assert user1_dislike_play_lists_count == @user1.disliked_play_lists_count,'不喜欢次数恢复'
    assert user2_disliked_play_lists_count == @user2.dislike_play_lists_count,'被不喜欢次数恢复'
    assert play_list_liked_play_lists_count + 1 == @play_list_user2.vote_up,'播放列表的喜欢数+1'
    assert play_list_disliked_count == @play_list_user2.vote_down,''
    assert @play_list_user2.liked_user_ids.include?(@user1.id),'播放列表记录了喜欢者'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
    ## 喜欢后 被不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_play_lists_count + 1 == @user1.disliked_play_lists_count,'不喜欢这个播放列表的用户的不喜欢表达总次数+1'
    assert user2_disliked_play_lists_count + 1 == @user2.dislike_play_lists_count,'被不喜欢这个播放列表的用户的被不喜欢总次数+1'
    assert play_list_liked_play_lists_count +1 -1== @play_list_user2.vote_up,'原来喜欢，被不喜欢后，播放列表的喜欢和之前的之前一样了'
    assert play_list_disliked_count + 1 == @play_list_user2.vote_down,'被不喜欢后，播放列表的不喜欢次数+1'
    assert @play_list_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的不喜欢人记录了不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ##不喜欢后被撤销不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_play_lists_count == @user1.disliked_play_lists_count,'撤销不喜欢这个播放列表的用户的不喜欢表达总次数，就不变了'
    assert user2_disliked_play_lists_count  == @user2.dislike_play_lists_count,'撤销被不喜欢这个播放列表的用户的被不喜欢总次数，不变了'
    assert play_list_liked_play_lists_count == @play_list_user2.vote_up,'撤销被不喜欢后，播放列表的喜欢次数保持不变'  
    assert play_list_disliked_count  == @play_list_user2.vote_down,'撤销被不喜欢后，播放列表的不喜欢次数不变'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'撤销被不喜欢后，播放列表的不喜欢人撤销不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ## 被喜欢后，撤销喜欢
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    @user1.thank_play_list(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    @user1.thank_play_list(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_like_play_lists_count == @user1.liked_play_lists_count,'喜欢后撤销喜欢，这个人又突然喜欢了这个播放列表，那么这个人的喜欢表达次数不变'
    assert user2_liked_play_lists_count  == @user2.like_play_lists_count,'喜欢后撤销，被喜欢这个播放列表的被喜欢次数不变'
    assert user1_dislike_play_lists_count == @user1.disliked_play_lists_count,'不喜欢次数恢复'
    assert user2_disliked_play_lists_count == @user2.dislike_play_lists_count,'被不喜欢次数恢复'
    assert play_list_liked_play_lists_count == @play_list_user2.vote_up,'播放列表的喜欢数'
    assert play_list_disliked_count == @play_list_user2.vote_down,'此时，喜欢和不喜欢没关系了'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'撤销喜欢，播放列表不记录记录了喜欢者'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
  end
  it "异步清理" do
    user_n = User.new
    user_n.save(:validate=>false)
    @user1.thanked_play_list_ids = []
    @user2.thanked_play_list_ids = []
    @user1.dislike_play_lists_count = 0
    @user1.like_play_lists_count = 0
    @user1.disliked_play_lists_count = 0
    @user1.liked_play_lists_count = 0
    @user2.dislike_play_lists_count = 0
    @user2.like_play_lists_count = 0
    @user2.disliked_play_lists_count = 0
    @user2.liked_play_lists_count = 0
    @user1.save(:validate=>false)
    @user2.save(:validate=>false)
    @user1.reload
    @user2.reload
    crazy_pl = PlayList.locate(user_n.id,"PL#{Time.now.to_i}#{rand}")
    crazy_pl.disliked_by_user(@user1)
    @user2.like_playlist(crazy_pl)
    # 1. 预检--------------    
    b1 = @user1.disliked_play_lists_count
    b2 = user_n.dislike_play_lists_count
    b3 = @user2.liked_play_lists_count
    b4 = user_n.like_play_lists_count
    # 2. 清理！！！--------------    
    crazy_pl.asynchronously_clean_me
    # 3. 重检--------------
    crazy_pl.reload
    user_n.reload
    @user1.reload
    @user2.reload
    # -----------------  
    assert b1-1 == @user1.disliked_play_lists_count,'复原计数'
    assert b2-1 == user_n.dislike_play_lists_count,'复原计数'
    assert b3-1 == @user2.liked_play_lists_count,'复原计数'
    assert b4-1 == user_n.like_play_lists_count,'复原计数'
  end
  it "软删除之后的逻辑" do
    # todo
    # 删除二阶搜索索引
  end
end