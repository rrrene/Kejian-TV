# -*- encoding : utf-8 -*-
require 'test_helper'
describe Course do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "向DZ要一个fid" do
    c = Course.new
    c.save(:validate=>false)
    c.reload
    refute c.fid.present?,'没有名字不能申请课程fid'
    c.update_attribute(:name,"Course#{Time.now.to_i}#{rand}")
    c.reload
    refute c.fid.present?,'没有学院fid不能申请课程fid'
    c.update_attribute(:department_fid,Department.nondeleted.gotfid.first.fid)
    c.reload
    assert c.fid.present?,'申请成功fid'
    assert 1==Course.where(fid:c.fid).count,'申请成功唯一的fid'
  end
  it "创建新课程并添加到某学院（上传课件时如果课程不够用，需要添加新课程）" do
    dpt = Department.nondeleted.gotfid.first                      ##to PSVR  不完整，如果是修改学院呢。上传的时候不用考虑貌似。
    dpt_courses_count = dpt.courses_count
    c = Course.new
    c.department_fid = dpt.fid
    c.save(:validate=>false)
    dpt.reload
    assert dpt_courses_count +1 == dpt.courses_count,'新的课程属于某个学院，这个学院的课程总数+1'
  end
  it "往课程里添加老师（上传课件时如果老师不够用，需要添加新老师）" do
    dpt = Department.nondeleted.gotfid.first
    c = Course.new
    c.department_fid = dpt.fid
    c.save(:validate=>false)
    t1 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t2 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t3 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t1.courses_count = 0
    t2.courses_count = 0
    t3.courses_count = 0
    c.teachers_count = 0
    t1.save(:validate=>false)
    t2.save(:validate=>false)
    t3.save(:validate=>false)
    c.save(:validate=>false)
    c.update_attribute(:teachers,[t1.name,t2.name])
    t1.reload
    t2.reload
    t3.reload
    c.reload
    assert 1==t1.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 1==t2.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 0==t3.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 2==c.teachers_count,'课程有了新的老师，课程的老师计数相应调整'
    c.update_attribute(:teachers,[t3.name])
    t1.reload
    t2.reload
    t3.reload
    c.reload
    assert 0==t1.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 0==t2.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 1==t3.courses_count,'课程有了新的老师，这个老师的课程计数相应调整'
    assert 1==c.teachers_count,'课程有了新的老师，课程的老师计数相应调整'
  end
  it "一阶搜索" do
    #todo
  end
  it "软删除之前判断是否有课件依赖于这个课程" do
    user_n = User.new
    user_n.save(:validate=>false)
    dpt = Department.nondeleted.gotfid.first
    c = Course.new
    c.department_fid = dpt.fid
    c.name = "Course#{Time.now.to_i}#{rand}"                                    ####To PSVR  Course need a name to generate fid
    c.save(:validate=>false)
    c_other = Course.nondeleted.gotfid.where(:id.ne=>c.id).first
    ret = c.instance_eval(&Course.before_soft_delete)
    assert true==ret,'没有任何课件依赖，可以进行删除'
    cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    cw.course_fid = c.fid
    cw.save(:validate=>false)
    c.reload
    ret = c.instance_eval(&Course.before_soft_delete)
    assert false==ret,'增加了课件依赖，不能进行删除'
    cw.course_fid = c_other.fid
    cw.save(:validate=>false)
    c.reload
    ret = c.instance_eval(&Course.before_soft_delete)
    refute false==ret,'解除课件依赖，可以进行删除'
  end
  it "异步清理" do
    @user1.followed_course_fids=[]
    @user1.save(:validate=>false)
    @user1.reload
    @user2.followed_course_fids=[]
    @user2.save(:validate=>false)
    @user2.reload
    dpt = Department.nondeleted.gotfid.first
    t1 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t2 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t3 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    crazy_course = Course.new
    crazy_course.department_fid = dpt.fid
    crazy_course.teachers = [t1.name,t2.name,t3.name]
    crazy_course.save(:validate=>false)
    @user1.follow_course(crazy_course)
    @user2.follow_course(crazy_course)
    # 1. 预检--------------    
    crazy_course.reload
    dpt.reload
    @user1.reload
    @user2.reload
    t1.reload
    t2.reload
    t3.reload
    dpt_courses_count = dpt.courses_count
    t1_courses_count = t1.courses_count
    t2_courses_count = t2.courses_count
    t3_courses_count = t3.courses_count
    # 2. 清理！！！-------------- 
    crazy_course.asynchronously_clean_me
    # 3. 重检--------------
    crazy_course.reload
    dpt.reload
    @user1.reload
    @user2.reload
    t1.reload
    t2.reload
    t3.reload
    refute @user1.followed_course_fids.include?(crazy_course.id),'清除关注课程赃引用'
    refute @user2.followed_course_fids.include?(crazy_course.id),'清除关注课程赃引用'
    binding.pry if dpt_courses_count - 1 != dpt.courses_count
    assert dpt_courses_count - 1 == dpt.courses_count,'所属院系的课程计数还原'
    assert t1_courses_count - 1 == t1.courses_count,'老师的课程计数还原'
    assert t2_courses_count - 1 == t2.courses_count,'老师的课程计数还原'
    assert t3_courses_count - 1 == t3.courses_count,'老师的课程计数还原'    
    refute t1.soft_deleted?,'课程没了老师不能没'
    refute t2.soft_deleted?,'课程没了老师不能没'
    refute t3.soft_deleted?,'课程没了老师不能没'
    refute dpt.soft_deleted?,'课程没了院系不能没'
  end
  it "课程的一阶索引" do
    user_n = User.new
    user_n.save(:validate=>false)
    pl = Course.new
    title = "pppppssssssvvvvvvrrrrrcc#{Course.count+1}"
    pl.name = title
    pl.save(:validate=>false)
    refute Redis::Search.query("Course", title).try(:[],0).try(:[],'id') == pl.id.to_s, '信息不全，不建立一阶索引'
    pl.update_attribute(:department_fid,Department.nondeleted.gotfid.first.fid)
    assert Redis::Search.query("Course", title).try(:[],0).try(:[],'id') == pl.id.to_s, '信息齐全后，保存即建立这个课程的一阶索引'
    
    title2 = title.reverse
    assert title2!=title
    pl.update_attribute(:name, title2)
    refute Redis::Search.query("Course", title).try(:[],0).try(:[],'id') == pl.id.to_s, '标题改了，老标题索引不再存在'    
    assert Redis::Search.query("Course", title2).try(:[],0).try(:[],'id') == pl.id.to_s, '标题改了，新标题索引存在'    
    pl.update_attribute(:name, title)
    assert Redis::Search.query("Course", title).try(:[],0).try(:[],'id') == pl.id.to_s, '软删除之后删除课程的一阶索引'
    pl.instance_eval(&Course.after_soft_delete)
    refute Redis::Search.query("Course", title).try(:[],0).try(:[],'id') == pl.id.to_s, '软删除之后删除课程的一阶索引'
  end

end


