# -*- encoding : utf-8 -*-
require "test_helper"

describe Courseware do
  before do 
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
    @courseware = Courseware.where(:uploader_id=>@user1.id).nondeleted.normal.is_father.first
    @courseware.thanked_user_ids = []
    @courseware.disliked_user_ids = []
    @user1.thanked_courseware_ids = []
    @user2.thanked_courseware_ids = []

    @user1.save(:validate=>false)
    @user2.save(:validate=>false)
    @courseware.save(:validate=>false)

    @courseware.reload    
    @user1.reload
    @user2.reload

  end
  it "转码完毕的课件改变作者，作者的课件计数作出相应变化" do
    user1_coursewares_uploaded_count_before = @user1.coursewares_uploaded_count
    user2_coursewares_uploaded_count_before = @user2.coursewares_uploaded_count
    @courseware.uploader_id = @user2.id
    @courseware.save(:validate=>false)
    @user1.reload
    @user2.reload
    assert user2_coursewares_uploaded_count_before + 1 == @user2.coursewares_uploaded_count,'课件改了作者，新的作者的课件数应该在保存之后被+1'
    assert user1_coursewares_uploaded_count_before - 1 == @user1.coursewares_uploaded_count,'课件改了作者，旧的作者的课件数应该在保存之后被-1'
    @courseware.uploader_id = @user1.id
    @courseware.save(:validate=>false)
    @user1.reload
    @user2.reload
    assert user2_coursewares_uploaded_count_before == @user2.coursewares_uploaded_count,'可恢复计数，当作者又被改回来了'
    assert user1_coursewares_uploaded_count_before == @user1.coursewares_uploaded_count,'可恢复计数，当作者又被改回来了'
  end
  it "转码没有完成的课件改变作者，作者的课件计数暂不变化" do
    user1_coursewares_uploaded_count_before = @user1.coursewares_uploaded_count
    @courseware = Courseware.new
    @courseware.status=1
    @courseware.uploader_id = @user1.id
    @courseware.save(:validate=>false)
    @user1.reload
    binding.pry if user1_coursewares_uploaded_count_before != @user1.coursewares_uploaded_count
    assert user1_coursewares_uploaded_count_before == @user1.coursewares_uploaded_count,'当改变了作者，但是课件还没有完成转码，不能+1'
    @courseware.status=0
    @courseware.save(:validate=>false)
    @user1.reload
    assert user1_coursewares_uploaded_count_before + 1 == @user1.coursewares_uploaded_count,'当改变了作者，而且课件转码完成了，才+1'
  end
  it "课件的
 oooO ↘┏━┓ ↙ Oooo 
 ( 踩)→┃顶┃ ←(踩 ) 
  \ ( →┃√┃ ← ) / 
　 \_)↗┗━┛ ↖(_/ 
" do
    @courseware_user2 = Courseware.where(:uploader_id=>@user2.id).nondeleted.normal.is_father.first
    @courseware_user2.thanked_user_ids = []
    @courseware_user2.disliked_user_ids = []
    @courseware_user2.save(:validate=>false)
    @courseware_user2.reload
    user1_dislike_coursewares_count = @user1.dislike_coursewares_count
    user2_disliked_coursewares_count = @user2.disliked_coursewares_count
    user1_thank_count = @user1.thank_count
    user2_thanked_count = @user2.thanked_count
    courseware_thanked_count = @courseware_user2.thanked_count
    courseware_disliked_count = @courseware_user2.disliked_count
    ## 被不喜欢
    @courseware_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    assert user1_dislike_coursewares_count + 1 == @user1.disliked_coursewares_count,'不喜欢这个课件的用户的不喜欢表达总次数+1'
    assert user2_disliked_coursewares_count + 1 == @user2.dislike_coursewares_count,'被不喜欢这个课件的用户的被不喜欢总次数+1'
    assert courseware_thanked_count == @courseware_user2.thanked_count,'被不喜欢后，课件的喜欢次数保持不变'  
    assert courseware_disliked_count + 1 == @courseware_user2.disliked_count,'被不喜欢后，课件的不喜欢次数+1'
    assert @courseware_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，课件的不喜欢人记录了不喜欢者'
    refute @courseware_user2.thanked_user_ids.include?(@user1.id),'被不喜欢后，课件的喜欢人就不再包含这个人了'
    ## 不喜欢后，被喜欢
    @user1.thank_courseware(@courseware_user2)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    assert user1_thank_count + 1 == @user1.thanked_count,'之后，这个人又突然喜欢了这个课件，那么这个人的喜欢表达次数+1'
    assert user2_thanked_count + 1 == @user2.thank_count,'被喜欢这个课件的被喜欢次数+1'
    assert user1_dislike_coursewares_count == @user1.disliked_coursewares_count,'不喜欢次数恢复'
    assert user2_disliked_coursewares_count == @user2.dislike_coursewares_count,'被不喜欢次数恢复'
    assert courseware_thanked_count + 1 == @courseware_user2.thanked_count,'课件的喜欢数+1'
    assert courseware_disliked_count == @courseware_user2.disliked_count,''
    assert @courseware_user2.thanked_user_ids.include?(@user1.id),'课件记录了喜欢者'
    refute @courseware_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
    ## 喜欢后 被不喜欢
    @courseware_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    assert user1_dislike_coursewares_count + 1 == @user1.disliked_coursewares_count,'不喜欢这个课件的用户的不喜欢表达总次数+1'
    assert user2_disliked_coursewares_count + 1 == @user2.dislike_coursewares_count,'被不喜欢这个课件的用户的被不喜欢总次数+1'
    assert courseware_thanked_count +1 -1== @courseware_user2.thanked_count,'原来喜欢，被不喜欢后，课件的喜欢和之前的之前一样了'
    assert courseware_disliked_count + 1 == @courseware_user2.disliked_count,'被不喜欢后，课件的不喜欢次数+1'
    assert @courseware_user2.disliked_user_ids.include?(@user1.id),'被不喜欢后，课件的不喜欢人记录了不喜欢者'
    refute @courseware_user2.thanked_user_ids.include?(@user1.id),'被不喜欢后，课件的喜欢人就不再包含这个人了'
    ##不喜欢后被撤销不喜欢
    @courseware_user2.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    assert user1_dislike_coursewares_count == @user1.disliked_coursewares_count,'撤销不喜欢这个课件的用户的不喜欢表达总次数，就不变了'
    assert user2_disliked_coursewares_count  == @user2.dislike_coursewares_count,'撤销被不喜欢这个课件的用户的被不喜欢总次数，不变了'
    assert courseware_thanked_count == @courseware_user2.thanked_count,'撤销被不喜欢后，课件的喜欢次数保持不变'  
    assert courseware_disliked_count  == @courseware_user2.disliked_count,'撤销被不喜欢后，课件的不喜欢次数不变'
    refute @courseware_user2.disliked_user_ids.include?(@user1.id),'撤销被不喜欢后，课件的不喜欢人撤销不喜欢者'
    refute @courseware_user2.thanked_user_ids.include?(@user1.id),'被不喜欢后，课件的喜欢人就不再包含这个人了'
    ## 被喜欢后，撤销喜欢
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    @user1.thank_courseware(@courseware_user2)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    @user1.thank_courseware(@courseware_user2)
    @user1.reload
    @user2.reload
    @courseware_user2.reload
    assert user1_thank_count == @user1.thanked_count,'喜欢后撤销喜欢，这个人又突然喜欢了这个课件，那么这个人的喜欢表达次数不变'
    assert user2_thanked_count  == @user2.thank_count,'喜欢后撤销，被喜欢这个课件的被喜欢次数不变'
    assert user1_dislike_coursewares_count == @user1.disliked_coursewares_count,'不喜欢次数恢复'
    assert user2_disliked_coursewares_count == @user2.dislike_coursewares_count,'被不喜欢次数恢复'
    assert courseware_thanked_count == @courseware_user2.thanked_count,'课件的喜欢数'
    assert courseware_disliked_count == @courseware_user2.disliked_count,'此时，喜欢和不喜欢没关系了'
    refute @courseware_user2.thanked_user_ids.include?(@user1.id),'撤销喜欢，课件不记录记录了喜欢者'
    refute @courseware_user2.disliked_user_ids.include?(@user1.id),'不喜欢者里不再包含这个人'
  end
  it "当一个课件添加到一个课程的时候，这个课程的课件总计数应该做出相应改变" do
    c = Courseware.new
    cc = Course.first
    c.course_fid = cc.fid
    cc_coursewares_count = cc.coursewares_count
    c.save(:validate=>false)
    cc.reload
    assert cc.coursewares_count == cc_coursewares_count + 1,"当一个课件添加到一个课程的时候，这个课程的课件总计数应+1"
    ccc = Course.where(:fid.ne=>cc.fid).first
    c.course_fid = ccc.fid
    ccc_coursewares_count =ccc.coursewares_count
    c.save(:validate=>false)
    ccc.reload
    cc.reload
    assert cc.coursewares_count == cc_coursewares_count,"课件的课程被修改了，那么原来老的课程的课件总计数恢复"
    assert ccc.coursewares_count == ccc_coursewares_count +1,"课件的课程被修改了，新的课程的课件计数+1"
  end

end
