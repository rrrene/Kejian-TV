# -*- encoding : utf-8 -*-
require 'test_helper'
describe Teacher do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "用一个名字定位一个老师" do
    name = "TCH#{Time.now.to_i}#{rand}"
    assert Teacher.where(:name => name).first.nil?,"为了测试，这个名字肯定不存在"
    tch = Teacher.locate(name)
    assert tch.persisted? && name==tch.name,"如果没有这个名字的老师，定位后就有了"
  end
  it "老师是有学院的" do
    t = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    dpt = Department.nondeleted.first
    d1 = dpt.teachers_count
    t.department_fid = dpt.fid
    t.save(:validate=>false)
    dpt.reload
    assert d1+1==dpt.teachers_count,'一旦老师的department_fid被指定，学院需要更新其老师计数'
    t.department_fid = nil
    t.save(:validate=>false)
    dpt.reload
    assert d1==dpt.teachers_count,'学院的老师计数还原'
  end
  it "软删除之前判断是否有课件依赖于这个老师" do
    t = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t_other = Teacher.nondeleted.first
    ret = t.instance_eval(&Teacher.before_soft_delete)
    refute false==ret,'没有任何课件依赖，可以进行删除'
    cw=Courseware.non_redirect.nondeleted.normal.is_father.first
    cw.teachers << t.name
    cw.teachers.uniq!
    cw.save(:validate=>false)
    t.reload
    ret = t.instance_eval(&Teacher.before_soft_delete)
    assert false==ret,'增加了课件依赖，不能进行删除'
    cw.teachers.delete t.name
    cw.save(:validate=>false)
    t.reload
    ret = t.instance_eval(&Teacher.before_soft_delete)
    refute false==ret,'解除课件依赖，可以进行删除'
  end
  it "异步清理" do
    @user1.followed_teacher_ids=[]
    @user1.save(:validate=>false)
    @user1.reload
    @user2.followed_teacher_ids=[]
    @user2.save(:validate=>false)
    @user2.reload
    dpt = Department.nondeleted.first
    cc = Course.nondeleted
    c1 = cc[0]
    c2 = cc[1]
    c3 = cc[2]
    crazy_teacher = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    crazy_teacher.department_fid = dpt.fid
    c1.teachers << crazy_teacher.name
    c2.teachers << crazy_teacher.name
    c3.teachers << crazy_teacher.name
    c1.save(:validate=>false) 
    c2.save(:validate=>false) 
    c3.save(:validate=>false) 
    @user1.follow_teacher(crazy_teacher)
    @user2.follow_teacher(crazy_teacher)
    # 1. 预检--------------    
    crazy_teacher.reload
    dpt.reload
    @user1.reload
    @user2.reload
    c1.reload
    c2.reload
    c3.reload
    d0 = dpt.teachers_count
    d1 = c1.teachers_count
    d2 = c2.teachers_count
    d3 = c3.teachers_count
    # 2. 清理！！！--------------    
    crazy_teacher.asynchronously_clean_me
    # 3. 重检--------------
    crazy_teacher.reload
    dpt.reload
    @user1.reload
    @user2.reload
    c1.reload
    c2.reload
    c3.reload
    assert crazy_teacher.soft_deleted?
    refute @user1.followed_teacher_ids.include?(crazy_teacher.id),'清除关注课程赃引用'
    refute @user2.followed_teacher_ids.include?(crazy_teacher.id),'清除关注课程赃引用'
    assert d0 - 1 == dpt.teachers_count,'所属院系的老师计数还原'
    assert d1 - 1 == c1.teachers_count,'课程的老师计数还原'
    assert d2 - 1 == c2.teachers_count,'课程的老师计数还原'
    assert d3 - 1 == c3.teachers_count,'课程的老师计数还原'
    refute dpt.soft_deleted?,'老师没了院系不能没'
    refute c1.soft_deleted?,'老师没了课程不能没'
    refute c2.soft_deleted?,'老师没了课程不能没'
    refute c3.soft_deleted?,'老师没了课程不能没'
  end

end
