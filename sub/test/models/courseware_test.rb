# -*- encoding : utf-8 -*-
require "test_helper"

describe Courseware do
  before do 
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
    @courseware = Courseware.where(:uploader_id=>@user1.id).non_redirect.nondeleted.normal.is_father.first

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

    @courseware_user2 = Courseware.where(:uploader_id=>@user2.id).non_redirect.nondeleted.normal.is_father.first
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
  it "当一个课件的所属课程发生了改变，新旧课程的课件总计数，以及新旧课程所属学院的课件总计数，都应该做出相应改变" do
    c = Courseware.new
    cc = Course.nondeleted.where(:department_fid.ne=>nil).first
    cc.department_ins.ua(:coursewares_count,0)
    cc.coursewares_count = 0
    cc.save(:validate=>false)
    cc.reload
    dpt = cc.department_ins.reload
    c.course_fid = cc.fid
    cc_coursewares_count = cc.coursewares_count
    dpt_coursewares_count = dpt.coursewares_count
    c.save(:validate=>false)
    cc.reload
    dpt.reload
    c.reload
    assert cc.coursewares_count == cc_coursewares_count + 1,"当一个课件的所属课程发生了改变，这个课程的课件总计数应+1"
    assert dpt.coursewares_count == dpt_coursewares_count + 1,"当一个课件的所属课程发生了改变，这个课程所属学院的课件总计数应+1"
    # -------------------------
    ccc = Course.nondeleted.where(:id.ne=>cc.id,:department_fid.nin=>[cc.department_fid,nil]).first
    dpt2 = ccc.department_ins                                       
    c.course_fid = ccc.fid
    ccc_coursewares_count =ccc.coursewares_count
    dpt2_coursewares_count = dpt2.coursewares_count
    c.save(:validate=>false)
    ccc.reload
    cc.reload
    dpt2.reload
    dpt.reload                                                    ##  need reload,Liber add
    assert cc.coursewares_count == cc_coursewares_count,"当一个课件的所属课程发生了改变，那么原来老的课程的课件总计数恢复"
    assert ccc.coursewares_count == ccc_coursewares_count +1,"当一个课件的所属课程发生了改变，新的课程的课件计数+1"
    assert dpt.coursewares_count == dpt_coursewares_count,"当一个课件的所属课程发生了改变，原来老的课程所属学院的课件总计数恢复"  
    assert dpt2.coursewares_count == dpt2_coursewares_count + 1,"当一个课件的所属课程发生了改变，新的课程所属学院的课件总计数应+1"
  end
  it "当一个课件的填了不存在的老师姓名，保存后这个老师就存在了" do
    name = "FUCK#{Time.now.to_i}"
    assert Teacher.where(name:name).first.nil?,'为了测试，这个名字必须不能存在'
    c = Courseware.new
    c.teachers = [name]
    c.save(:validate=>false)
    refute Teacher.where(name:name).first.nil?,'保存后这个老师就存在了'
  end
  it "当一个课件的所属老师发生了改变，这个老师的课件总计数应该做出相应改变" do
    c = Courseware.new
    c.uploader_id = @user1.id         ##需要加上这句话~Liber加
    c.status = 0                      ##需要加上这句话，否则逻辑冲突,如果status!=0不会加1~~Liber加
    cc = Teacher.nondeleted.first
    c.teachers = [cc.name]
    cc_coursewares_count = cc.coursewares_count
    c.save(:validate=>false)
    cc.reload
    c.reload
    assert cc.coursewares_count == cc_coursewares_count + 1,"当一个课件添加到一个老师的时候，这个老师的课件总计数应+1"
    ccc = Teacher.nondeleted.where(:id.ne=>cc.id).first
    c.teachers = [ccc.name]                                     ##老师可能重名。。。disaster
    ccc_coursewares_count =ccc.coursewares_count
    c.save(:validate=>false)
    ccc.reload
    cc.reload
    assert cc.coursewares_count == cc_coursewares_count,"课件的老师被修改了，那么原来老的老师的课件总计数恢复"
    assert ccc.coursewares_count == ccc_coursewares_count +1,"课件的老师被修改了，新的老师的课件计数+1"
  end
  it "当一个课件的上传人发生了改变，这个上传人的课件总计数应该做出相应改变" do
    c = Courseware.new
    c.status = 0                      ##需要加上这句话，否则逻辑冲突哦~~Liber加
    cc = User.nondeleted.first
    c.uploader_id = cc.id
    cc_coursewares_uploaded_count = cc.coursewares_uploaded_count
    c.save(:validate=>false)
    cc.reload
    c.reload
    assert cc.coursewares_uploaded_count == cc_coursewares_uploaded_count + 1,"当一个课件添加到一个上传人的时候，这个上传人的课件总计数应+1"
    # -----------------------
    cc2 = User.nondeleted.where(:id.ne=>cc.id).first
    cc2_coursewares_uploaded_count = cc2.coursewares_uploaded_count
    c.uploader_id_candidates = [cc2.id]
    c.save(:validate=>false)
    cc2.reload
    assert cc2.coursewares_uploaded_count == cc2_coursewares_uploaded_count,"当一个课件添加到一个上传人的时候，这个上传人的课件总计数不应该+1"  
    # -----------------------
    ccc = User.nondeleted.where(:id.nin=>[cc.id,cc2.id]).first
    c.uploader_id = ccc.id
    ccc_coursewares_uploaded_count =ccc.coursewares_uploaded_count
    c.save(:validate=>false)
    ccc.reload
    cc.reload
    assert cc.coursewares_uploaded_count == cc_coursewares_uploaded_count,"课件的上传人被修改了，那么原来老的上传人的课件总计数恢复"
    assert ccc.coursewares_uploaded_count == ccc_coursewares_uploaded_count +1,"课件的上传人被修改了，新的上传人的课件计数+1"
  end
  it "一级重定向" do
    # 与另一人的课件重复
    cw = Courseware.new
    cw.uploader_id = @user2.id
    cw.redirect_to_id = @courseware.id # 注意@courseware属于@user1
    cw.save(:validate=>false)
    cw.reload
    assert 1==cw.uploader_id_candidates.count(@user2.id),'用户被加入候选uploader_id'
    # 与本人的课件重复
    cw = Courseware.new
    cw.uploader_id = @user1.id
    cw.redirect_to_id = @courseware.id # 注意@courseware属于@user1
    cw.save(:validate=>false)
    cw.reload
    assert 0==cw.uploader_id_candidates.count(@user1.id),'用户与主uploader_id相同则不会被加入候选uploader_id'
    assert @user1.id==cw.uploader_id,'uploader_id依然是uploader_id'
    # Courseware创建后的延迟手工判重
    other_courseware = Courseware.non_redirect.nondeleted.normal.is_father.where(:id.ne=>@courseware.id,:uploader_id.nin=>[@user1.id,@user2.id]).first
    other_courseware_uploader_id = other_courseware.uploader_id
    other_courseware.uploader_id_candidates = []
    @courseware.redirect_to_id = other_courseware.id # 注意@courseware属于@user1
    @courseware.save(:validate=>false)
    other_courseware.save(:validate=>false)
    other_courseware.reload
    assert 1==other_courseware.uploader_id_candidates.count(@user1.id),'用户被加入候选uploader_id'
    assert other_courseware_uploader_id == other_courseware.uploader_id,'uploader_id依然是uploader_id'
    new_cw = Courseware.new
    new_cw.uploader_id = @user1.id
    new_cw.redirect_to_id = other_courseware.id # 注意@courseware属于@user1
    new_cw.save(:validate=>false)
    other_courseware.reload
    assert 1==other_courseware.uploader_id_candidates.count(@user1.id),'用户被已经被加入候选uploader_id，不要重复加入'
    assert other_courseware_uploader_id == other_courseware.uploader_id,'uploader_id依然是uploader_id'
    @courseware.redirect_to_id = nil
    @courseware.save(:validate=>false)
    other_courseware.save(:validate=>false)
    other_courseware.reload
    assert 1==other_courseware.uploader_id_candidates.count(@user1.id),'用户不能被清除于候选uploader_id，因为还有一个课件指向它'
    assert other_courseware_uploader_id == other_courseware.uploader_id,'uploader_id依然是uploader_id'
    new_cw.uploader_id = @user2.id
    new_cw.save(:validate=>false)
    other_courseware.reload
    assert 0==other_courseware.uploader_id_candidates.count(@user1.id),'用户被清除于候选uploader_id，因为没有任何课件指向它了'
    assert 1==other_courseware.uploader_id_candidates.count(@user2.id),'当已经设置了redirect_to_id的时候修改uploader_id，需要设置新的uploader_id_candidates'
    assert other_courseware_uploader_id == other_courseware.uploader_id,'uploader_id依然是uploader_id'
    # 已转向的情况下再转向
    new_cw2 = Courseware.new
    new_cw2.uploader_id = @user1.id
    new_cw2.save(:validate=>false)
    new_cw.redirect_to_id = new_cw2.id # 注意@courseware属于@user1
    new_cw.save(:validate=>false)
    other_courseware.reload
    assert other_courseware.uploader_id_candidates.empty?,'没有任何课件指向other_courseware了'
    assert other_courseware_uploader_id == other_courseware.uploader_id,'uploader_id依然是uploader_id'    
    new_cw2.reload
    assert [@user2.id] == new_cw2.uploader_id_candidates,'需要清除以前的uploader_id_candidates'
    assert new_cw2.uploader_id == @user1.id,'uploader_id依然是uploader_id'    
  end
  it "多级重定向消除为一级重定向" do
    cw1 = Courseware.new;cw1.uploader_id = @user1.id;
    cw2 = Courseware.new;cw2.uploader_id = @user2.id;
    cw3 = Courseware.new;u3=User.new;u3.save(:validate=>false);cw3.uploader_id = u3.id;
    cw4 = Courseware.new;u4=User.new;u4.save(:validate=>false);cw4.uploader_id = u4.id;
    cw1.redirect_to_id = @courseware.id
    cw2.redirect_to_id = cw1.id
    cw3.redirect_to_id = cw2.id
    cw4.redirect_to_id = cw2.id
    cw1.save(:validate=>false)
    cw2.save(:validate=>false)
    cw3.save(:validate=>false)
    cw4.save(:validate=>false)
    cw1.reload
    cw2.reload
    cw3.reload
    cw4.reload
    @courseware.reload
    assert cw1.redirect_to_id == @courseware.id,'连环重定向需传递闭包'
    assert cw2.redirect_to_id == @courseware.id,'连环重定向需传递闭包'
    assert cw3.redirect_to_id == @courseware.id,'连环重定向需传递闭包'
    assert cw4.redirect_to_id == @courseware.id,'连环重定向需传递闭包'
    assert 1==@courseware.uploader_id_candidates.count(@user1.id),'连环重定向需传递闭包'
    assert 1==@courseware.uploader_id_candidates.count(@user2.id),'连环重定向需传递闭包'
    assert 1==@courseware.uploader_id_candidates.count(u3.id),'连环重定向需传递闭包'
    assert 1==@courseware.uploader_id_candidates.count(u4.id),'连环重定向需传递闭包'
    # ---
    @courseware.redirect_to_id = cw2.id
    @courseware.save(:validate=>false)
    assert @courseware.redirect_to_id.nil?,'发现重定向环时应改设此定向关系为nil'
  end
  it "软删除逻辑" do
    # todo:删除课件时，判断candidates
  end
  it "硬删除逻辑" do
  end
end
