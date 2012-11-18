# -*- encoding : utf-8 -*-
require 'test_helper'
describe Department do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "DZ" do
    # todo
  end
  it "软删除之前判断是否有课程依赖于这个院系" do
    # -------
    dpt = Department.new
    fid = 9999+(rand*1000).to_i
    while Department.where(fid:fid).first
      fid = 9999+(rand*1000).to_i
    end
    dpt.fid=fid
    dpt.save(:validate=>false)
    # -------
    c = Course.nondeleted.first
    dpt_other = Department.nondeleted.first
    ret = dpt.instance_eval(&Department.before_soft_delete)
    refute false==ret,'没有任何依赖，可以进行删除'
    c.department_fid = dpt.fid
    c.save(:validate=>false)
    dpt.reload
    ret = dpt.instance_eval(&Department.before_soft_delete)
    assert false==ret,'增加了课程依赖，不能进行删除'
    c.department_fid = dpt_other.fid
    c.save(:validate=>false)
    dpt.reload
    ret = dpt.instance_eval(&Department.before_soft_delete)
    refute false==ret,'解除课件依赖，可以进行删除'
  end
  it "异步清理" do
    @user1.followed_department_fids=[]
    @user2.followed_department_fids=[]
    @user1.save(:validate=>false)
    @user1.reload
    @user2.save(:validate=>false)
    @user2.reload
    # -------
    crazy_dpt = Department.new
    fid = 9999+(rand*1000).to_i
    while Department.where(fid:fid).first
      fid = 9999+(rand*1000).to_i
    end
    crazy_dpt.fid=fid
    crazy_dpt.save(:validate=>false)
    # -------
    @user1.follow_department(crazy_dpt)
    @user2.follow_department(crazy_dpt)
    # 1. 预检--------------
    # 2. 清理！！！-------------- 
    crazy_dpt.asynchronously_clean_me
    # 3. 重检--------------
    crazy_dpt.reload
    @user1.reload
    @user2.reload
    assert crazy_dpt.soft_deleted?
    refute @user1.followed_department_fids.include?(crazy_dpt.fid),'followed_department_fids复原'
    refute @user2.followed_department_fids.include?(crazy_dpt.fid),'followed_department_fids复原'
  end
end
