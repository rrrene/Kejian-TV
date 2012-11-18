# -*- encoding : utf-8 -*-
require 'test_helper'
describe Course do
  before do 
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "创建新课程并添加到某学院（上传课件时如果课程不够用，需要添加新课程）" do
    dpt = Department.first
    crazy_course = Course.new
    crazy_course.department_fid = dpt.fid
    crazy_course.save(:validate=>false)
    
  end
  it "被添加老师（上传课件时如果老师不够用，需要添加新老师）" do
    
  end
  it "软删除之前判断是否有课件填写了这个课程，判断是否有课件锦囊依赖于这个课程" do
    user_n = User.new
    user_n.save(:validate=>false)
    dpt = Department.first
    c = Course.new
    c.department_fid = dpt.fid
    c.save(:validate=>false)
    ret = c.instance_eval(&Course.before_soft_delete)
    refute false==ret,'没有任何课件依赖，可以进行删除'
  end
  it "异步清理" do
    dpt = Department.first
    t1 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t2 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    t3 = Teacher.locate("TCH#{Time.now.to_i}#{rand}")
    crazy_course = Course.new
    crazy_course.department_fid = dpt.fid
    crazy_course.teachers = [t1.name,t2.name,t3.name]
    crazy_course.save(:validate=>false)
    @user1.followed_course_fids=[]
    @user1.save(:validate=>false)
    @user1.reload
    @user1.unfollow_course(crazy_course)
    # 1. 预检--------------    
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
    # -----------------  
    refute @user1.followed_course_fids.include?(crazy_course.id),'清除关注课程赃引用'
    assert dpt_courses_count - 1 == dpt.courses_count,'所属院系的课程计数还原'
    t1_courses_count = t1.courses_count
    t2_courses_count = t2.courses_count
    t3_courses_count = t3.courses_count    
  end

end