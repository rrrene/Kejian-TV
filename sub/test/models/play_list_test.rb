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
    assert play_list.persisted? && play_list.title == name,"如果没有这个名字的播放列表，定位后就有了"
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
  it "播放列表放入物品之时，要计算总的status" do
    ss = Courseware.non_redirect.nondeleted.normal.is_father
    cw1=ss[0]
    cw2=ss[1]
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    play_list.add_one_thing(cw1.id)
    play_list.reload
    refute 0==play_list.status,'只有一个课件=>不正常'
    play_list.add_one_thing(cw2.id)
    play_list.reload
    assert 0==play_list.status,'两个正常课件=>正常'
    cw3 = Courseware.new
    cw1.ktvid = nil
    cw3.uploader_id = @user1.id
    cw3.status=0
    cw3.save(:validate=>false)
    play_list.add_one_thing(cw3.id)    
    play_list.reload
    refute 0==play_list.status,'放入了没有ktvid的课件=>不正常'
    play_list.content.delete(cw3.id)
    play_list.save(:validate=>false)
    play_list.reload
    assert 0==play_list.status,'取出了没有ktvid的课件=>正常'
    cw4 = Courseware.new
    cw4.ktvid = '5058960ce13823076c00002e'
    cw4.uploader_id = @user1.id
    cw4.status=-1
    cw4.save(:validate=>false)
    play_list.add_one_thing(cw4.id)    
    play_list.reload
    refute 0==play_list.status,'放入了status不正常的课件=>不正常'    
  end

  it "播放列表放入物品之时，要计算更新播放列表的总页数" do
    ss=Courseware.where(:slides_count.gt=>0)
    cw1=ss[0]
    cw2=ss[1]
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")
    play_list.add_one_thing(cw1.id)
    play_list.reload
    assert cw1.slides_count==play_list.content_total_pages,'计算content_total_pages'
    play_list.add_one_thing(cw2.id)
    play_list.reload
    assert cw1.slides_count+cw2.slides_count==play_list.content_total_pages,'计算content_total_pages'
  end

  it "播放列表的course_fids的计算及多种播放列表计数变化" do
    cw1 = Courseware.non_redirect.nondeleted.normal.is_father.first
    c1 = cw1.course_ins
    dp1 = cw1.department_ins
    cw2 = Courseware.non_redirect.nondeleted.normal.is_father.where(:department_fid.ne=>cw1.department_fid).first
    c2 = cw2.course_ins
    dp2 = cw2.department_ins
    d1 = dp1.play_lists_count
    d2 = dp2.play_lists_count
    d3 = c1.play_lists_count
    d4 = c1.play_lists_count
    play_list = PlayList.locate(@user1.id,"PL#{Time.now.to_i}#{rand}")

    play_list.add_one_thing(cw1.id)
    dp1.reload
    dp2.reload
    c1.reload
    c2.reload
    play_list.reload
    assert 1==play_list.course_fids.count(cw1.course_fid),'加一个课件有一个课件的课程fid'
    assert 0==play_list.course_fids.count(cw2.course_fid),'加一个课件有一个课件的课程fid'
    assert d1+1==d1.play_lists_count,'课程的学院播放列表计数变化'
    assert d2==d2.play_lists_count,'课程的学院播放列表计数变化'
    assert d3+1==c1.play_lists_count,'课程播放列表计数变化'
    assert d4==c2.play_lists_count,'课程的学院播放列表计数变化'
    
    play_list.add_one_thing(cw2.id)
    dp1.reload
    dp2.reload
    c1.reload
    c2.reload
    play_list.reload
    assert 1==play_list.course_fids.count(cw1.course_fid),'加一个课件有一个课件的课程fid'
    assert 1==play_list.course_fids.count(cw2.course_fid),'加一个课件就有一个课件的课程fid'
    assert d1+1==d1.play_lists_count,'课程的学院播放列表计数变化'
    assert d2+1==d2.play_lists_count,'课程的学院播放列表计数变化'
    assert d3+1==c1.play_lists_count,'课程播放列表计数变化'
    assert d4+1==c2.play_lists_count,'课程的学院播放列表计数变化'

    play_list.content.delete(cw2.id)
    play_list.save(:validate=>false)
    dp1.reload
    dp2.reload
    c1.reload
    c2.reload
    play_list.reload
    assert 1==play_list.course_fids.count(cw1.course_fid),'没动的还在'
    assert 0==play_list.course_fids.count(cw2.course_fid),'没了cw2就没了cw2.course_fids'
    assert d1+1==d1.play_lists_count,'课程的学院播放列表计数变化'
    assert d2==d2.play_lists_count,'课程的学院播放列表计数变化'
    assert d3+1==c1.play_lists_count,'课程播放列表计数变化'
    assert d4==c2.play_lists_count,'课程的学院播放列表计数变化'
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
    user1_dislike_count = @user1.dislike_count
    user2_disliked_count = @user2.disliked_count
    user1_thank_count = @user1.thank_count
    user2_thanked_count = @user2.thanked_count
    play_list_thanked_count = @play_list_user2.vote_up
    play_list_disliked_count = @play_list_user2.vote_down
    ## 被不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_count + 1 == @user1.disliked_count,'不喜欢这个播放列表的用户的不喜欢表达总次数+1'
    assert user2_disliked_count + 1 == @user2.dislike_count,'被不喜欢这个播放列表的用户的被不喜欢总次数+1'
    assert play_list_thanked_count == @play_list_user2.vote_up,'被不喜欢后，播放列表的喜欢次数保持不变'  
    assert play_list_disliked_count + 1 == @play_list_user2.vote_down,'被不喜欢后，播放列表的不喜欢次数+1'
    assert @play_list_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的不喜欢人记录了不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ## 不喜欢后，被喜欢
    @user1.like_playlist(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_thank_count + 1 == @user1.thanked_count,'之后，这个人又突然喜欢了这个播放列表，那么这个人的喜欢表达次数+1'
    assert user2_thanked_count + 1 == @user2.thank_count,'被喜欢这个播放列表的被喜欢次数+1'
    assert user1_dislike_count == @user1.disliked_count,'不喜欢次数恢复'
    assert user2_disliked_count == @user2.dislike_count,'被不喜欢次数恢复'
    assert play_list_thanked_count + 1 == @play_list_user2.vote_up,'播放列表的喜欢数+1'
    assert play_list_disliked_count == @play_list_user2.vote_down,''
    assert @play_list_user2.liked_user_ids.include?(@user1.id),'播放列表记录了喜欢者'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
    ## 喜欢后 被不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_count + 1 == @user1.disliked_count,'不喜欢这个播放列表的用户的不喜欢表达总次数+1'
    assert user2_disliked_count + 1 == @user2.dislike_count,'被不喜欢这个播放列表的用户的被不喜欢总次数+1'
    assert play_list_thanked_count +1 -1== @play_list_user2.vote_up,'原来喜欢，被不喜欢后，播放列表的喜欢和之前的之前一样了'
    assert play_list_disliked_count + 1 == @play_list_user2.vote_down,'被不喜欢后，播放列表的不喜欢次数+1'
    assert @play_list_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的不喜欢人记录了不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ##不喜欢后被撤销不喜欢
    @play_list_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_dislike_count == @user1.disliked_count,'撤销不喜欢这个播放列表的用户的不喜欢表达总次数，就不变了'
    assert user2_disliked_count  == @user2.dislike_count,'撤销被不喜欢这个播放列表的用户的被不喜欢总次数，不变了'
    assert play_list_thanked_count == @play_list_user2.vote_up,'撤销被不喜欢后，播放列表的喜欢次数保持不变'  
    assert play_list_disliked_count  == @play_list_user2.vote_down,'撤销被不喜欢后，播放列表的不喜欢次数不变'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'撤销被不喜欢后，播放列表的不喜欢人撤销不喜欢者'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'被不喜欢后，播放列表的喜欢人就不再包含这个人了'
    ## 被喜欢后，撤销喜欢
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    @user1.like_playlist(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    @user1.like_playlist(@play_list_user2)
    @user1.reload
    @user2.reload
    @play_list_user2.reload
    assert user1_thank_count == @user1.thanked_count,'喜欢后撤销喜欢，这个人又突然喜欢了这个播放列表，那么这个人的喜欢表达次数不变'
    assert user2_thanked_count  == @user2.thank_count,'喜欢后撤销，被喜欢这个播放列表的被喜欢次数不变'
    assert user1_dislike_count == @user1.disliked_count,'不喜欢次数恢复'
    assert user2_disliked_count == @user2.dislike_count,'被不喜欢次数恢复'
    assert play_list_thanked_count == @play_list_user2.vote_up,'播放列表的喜欢数'
    assert play_list_disliked_count == @play_list_user2.vote_down,'此时，喜欢和不喜欢没关系了'
    refute @play_list_user2.liked_user_ids.include?(@user1.id),'撤销喜欢，播放列表不记录记录了喜欢者'
    refute @play_list_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
  end
  it "异步清理" do
    user_n = User.new
    user_n.save(:validate=>false)
    @user1.thanked_play_list_ids = []
    @user2.thanked_play_list_ids = []
    @user1.save(:validate=>false)
    @user2.save(:validate=>false)
    @user1.reload
    @user2.reload
    ss = Courseware.non_redirect.nondeleted.normal.is_father
    cw1=ss[0]
    cw2=ss[1]
    crazy_pl = PlayList.locate(user_n.id,"PL#{Time.now.to_i}#{rand}")
    crazy_pl.user_id = user_n.id
    crazy_pl.disliked_by_user(@user1)
    crazy_pl.add_one_thing(cw1.id)
    crazy_pl.add_one_thing(cw2.id)
    @user2.like_playlist(crazy_pl)
    # 1. 预检--------------    
    b1 = @user1.disliked_count
    b2 = user_n.dislike_count
    b3 = @user2.thanked_count
    b4 = user_n.thank_count
    # 2. 清理！！！--------------    
    crazy_pl.asynchronously_clean_me
    # 3. 重检--------------
    crazy_pl.reload
    user_n.reload
    @user1.reload
    @user2.reload
    # -----------------  
    assert b1-1 == @user1.disliked_count,'复原计数'
    assert b2-1 == user_n.dislike_count,'复原计数'
    assert b3-1 == @user2.thanked_count,'复原计数'
    assert b4-1 == user_n.thank_count,'复原计数'
    refute cw1.soft_deleted?,'播放列表没了，课件不能没啊！'
    refute cw2.soft_deleted?,'播放列表没了，课件不能没啊！'
  end

end
