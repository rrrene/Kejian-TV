# -*- encoding : utf-8 -*-
require "test_helper"

describe Courseware do
  before do 
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "normal_after_save_coursewares_uploaded_count" do
    @courseware = Courseware.where(:uploader_id=>@user1.id).nondeleted.normal.is_father.first
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
  it "abnormal_after_save_coursewares_uploaded_count" do
    user1_coursewares_uploaded_count_before = @user1.coursewares_uploaded_count
    @courseware = Courseware.new
    @courseware.status=1
    @courseware.uploader_id = @user1.id
    @courseware.save(:validate=>false)
    @user1.reload
    assert user1_coursewares_uploaded_count_before == @user1.coursewares_uploaded_count,'当改变了作者，但是课件还没有完成转码，不能+1'
    @courseware.status=0
    @courseware.save(:validate=>false)
    @user1.reload
    assert user1_coursewares_uploaded_count_before + 1 == @user1.coursewares_uploaded_count,'当改变了作者，而且课件转码完成了，才+1'
  end
  it "disliked_then_thanked_by_user" do
    @courseware = Courseware.nondeleted.normal.is_father.where(:uploader_id=>@user2.id).first
    user1_dislike_coursewares_count = @user1.dislike_coursewares_count
    user2_disliked_coursewares_count = @user2.disliked_coursewares_count
    user1_thank_coursewares_count = @user1.thank_coursewares_count
    user2_thanked_coursewares_count = @user2.thanked_coursewares_count
    courseware_thanked_count = @courseware.thanked_count
    courseware_disliked_count = @courseware.disliked_count
    @courseware.disliked_by_user(@user1)
    @user1.reload
    @user2.reload
    @courseware.reload
    assert user1_dislike_coursewares_count + 1 == @user1.dislike_coursewares_count,'不喜欢这个课件的用户的不喜欢表达总次数+1'
    assert user2_disliked_coursewares_count + 1 == @user2.disliked_coursewares_count,'被不喜欢这个课件的用户的被不喜欢总次数+1'
    # assert courseware_thanked_count == @courseware.thanked_count,'被不喜欢后，课件的喜欢次数保持不变'
    assert courseware_disliked_count + 1 == @courseware.disliked_count,'被不喜欢后，课件的不喜欢次数+1'
    assert @courseware.disliked_user_ids.include?(@user1),'被不喜欢后，课件的不喜欢人记录了不喜欢者'
    refute @courseware.thanked_user_ids.include?(@user1),'被不喜欢后，课件的喜欢人就不再包含这个人了'
    @user1.thank_courseware(@courseware)
    @user1.reload
    @user2.reload
    @courseware.reload
    assert user1_thank_coursewares_count + 1 == @user1.user1_thank_coursewares_count,'之后，这个人又突然喜欢了这个课件，那么这个人的喜欢表达次数+1'
    assert user2_thanked_coursewares_count + 1 == @user2.user2_thanked_coursewares_count,'被喜欢这个课件的被喜欢次数+1'
    assert user1_dislike_coursewares_count == @user1.dislike_coursewares_count,'不喜欢次数恢复'
    assert user2_disliked_coursewares_count == @user2.disliked_coursewares_count,'被不喜欢次数恢复'
    assert courseware_thanked_count + 1 == @courseware.thanked_count,'课件的喜欢数+1'
    assert courseware_disliked_count == @courseware.disliked_count,'课件的不喜欢数恢复'
    assert @courseware.thanked_user_ids.include?(@user1),'课件记录了喜欢者'
    refute @courseware.disliked_user_ids.include?(@user1),'不喜欢者里不再包含这个人'
  end
end
