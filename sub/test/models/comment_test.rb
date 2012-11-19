# -*- encoding : utf-8 -*-
require "test_helper"
describe Comment do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  
  it "after_create_comments_count +1" do
    @courseware1 = Courseware.non_redirect.nondeleted.normal.is_father.first
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
  
  it "对课件进行评论" do
    @courseware1 = Courseware.non_redirect.nondeleted.normal.is_father.first
    success_cm1,cm1 = Comment.real_create({:comment => {"commentable_type"=>"Courseware","commentable_id"=>@courseware1.id.to_s,"body"=>"#{Time.now.to_i}#{rand.to_s}"}}.with_indifferent_access,@user1)
    success_cm2,cm2 = Comment.real_create({:comment => {"commentable_type"=>"Courseware","commentable_id"=>@courseware1.id.to_s,"body"=>"#{Time.now.to_i}#{rand.to_s}",'replied_to_comment_id'=>cm1.id.to_s}}.with_indifferent_access,@user2)
    success_cm3,cm3 = Comment.real_create({:comment => {"commentable_type"=>"Courseware","commentable_id"=>@courseware1.id.to_s,"body"=>"#{Time.now.to_i}#{rand.to_s}"}}.with_indifferent_access,@user1)
    assert success_cm1,'成功保存评论'
    assert success_cm2,'成功保存评论'
    assert success_cm3,'成功保存评论'
    assert @courseware1.comments.collect(&:body).include?(cm1.body),'成功评论了课件'
    assert @courseware1.comments.collect(&:body).include?(cm2.body),'成功评论了课件'
    assert @courseware1.comments.collect(&:body).include?(cm3.body),'成功评论了课件'
  end
  it "异步清理" do
    @courseware1 = Courseware.non_redirect.nondeleted.normal.is_father.first
    # 1. 预检--------------    
    # 2. 清理！！！--------------    
    # 3. 重检--------------
    # -----------------  
  end

end
