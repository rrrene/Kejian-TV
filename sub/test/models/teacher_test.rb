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
    dpt = Department.first
    d1 = dpt.teachers_count
    t.department_fid = dpt.fid
    t.save(:validate=>false)
    dpt.reload
    assert d1+1==dpt.teachers_count,'一旦老师的department_fid被指定，学院需要更新其老师计数'
  end
  it "异步清理" do
    @user1.followed_teacher_ids=[]
    @user1.save(:validate=>false)
    @user1.reload
    @user2.followed_teacher_ids=[]
    @user2.save(:validate=>false)
    @user2.reload
    crazy_teacher = Teacher.new

    # 1. 预检--------------    
    # 2. 清理！！！--------------    
    # 3. 重检--------------
    # -----------------  
  end

end
