require "minitest_helper"

describe Courseware do
  def setup
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  def normal_after_save_coursewares_upload_count
    @courseware = Courseware.where(:uploader_id=>@user2.id).nondeleted.normal.is_father.first
    user1_coursewares_upload_count_before = @user1.coursewares_upload_count
    user2_coursewares_upload_count_before = @user2.coursewares_upload_count
    @courseware.uploader_id = @user1.id
    @courseware.save(:validate=>false)
    @user1.reload
    @user2.reload
    assert user1_coursewares_upload_count_before + 1 == @user1.coursewares_upload_count
    assert user2_coursewares_upload_count_before + 1 == @user2.coursewares_upload_count
    @courseware.uploader_id = @user2.id
    @courseware.save(:validate=>false)
    @user1.reload
    @user2.reload
    assert user1_coursewares_upload_count_before == @user1.coursewares_upload_count
    assert user2_coursewares_upload_count_before == @user2.coursewares_upload_count
  end
  def abnormal_after_save_coursewares_upload_count
    user1_coursewares_upload_count_before = @user1.coursewares_upload_count
    @courseware = Courseware.new
    @courseware.status=1
    @courseware.uploader_id = @user1.id
    @courseware.save(:validate=>false)    
    @user1.reload
    assert user1_coursewares_upload_count_before == @user1.coursewares_upload_count
    @courseware.status=0
    @courseware.save(:validate=>false)    
    @user1.reload
    assert user1_coursewares_upload_count_before + 1 == @user1.coursewares_upload_count
  end
  def disliked_then_thanked_by_user
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
    assert user1_dislike_coursewares_count + 1 == @user1.user1_dislike_coursewares_count
    assert user2_disliked_coursewares_count + 1 == @user2.user2_disliked_coursewares_count
    assert courseware_thanked_count == @courseware.thanked_count
    assert courseware_disliked_count + 1 == @courseware.disliked_count
    assert @courseware.disliked_user_ids.include?(@user1)
    refute @courseware.thanked_user_ids.include?(@user1)
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
