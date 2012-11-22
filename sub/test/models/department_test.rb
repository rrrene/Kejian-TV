# -*- encoding : utf-8 -*-
require 'test_helper'
describe Department do
  before do
    @user1 = User.find('506d5558e1382375f30000dc')
    @user2 = User.find('506d559ee1382375f3000163')
  end
  it "向DZ要一个fid" do
    dpt = Department.new
    dpt.save(:validate=>false)
    dpt.reload
    refute dpt.fid.present?,'没有名字不能申请fid'
    dpt.update_attribute(:name,"DPT#{Time.now.to_i}#{rand}")
    dpt.reload
    assert dpt.fid.present?,'申请成功fid'
    assert 1==Department.where(fid:dpt.fid).count,'申请成功唯一的fid'
  end
  it "软删除之前判断是否有课程或老师依赖于这个院系" do
    dpt = Department.new
    dpt.name="DPT#{Time.now.to_i}#{rand}"
    dpt.save(:validate=>false)
    c = Course.nondeleted.gotfid.first
    t = Teacher.nondeleted.first
    dpt_other = Department.nondeleted.gotfid.first
    ret = dpt.instance_eval(&Department.before_soft_delete)
    refute false==ret,'没有任何课程或老师依赖，可以进行删除'
    c.department_fid = dpt.fid
    c.save(:validate=>false)
    dpt.reload
    ret = dpt.instance_eval(&Department.before_soft_delete)
    assert false==ret,'增加了课程依赖，不能进行删除'
    c.department_fid = dpt_other.fid
    c.save(:validate=>false)
    t.department_fid = dpt.fid
    t.save(:validate=>false)
    dpt.reload
    ret = dpt.instance_eval(&Department.before_soft_delete)
    assert false==ret,'增加了老师依赖，不能进行删除'
    t.department_fid = dpt_other.fid
    t.save(:validate=>false)
    dpt.reload
    ret = dpt.instance_eval(&Department.before_soft_delete)
    refute false==ret,'解除课程和老师依赖，可以进行删除'
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
    crazy_dpt.name="DPT#{Time.now.to_i}#{rand}"
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
    refute @user1.followed_department_fids.include?(crazy_dpt.fid),'followed_department_fids复原'
    refute @user2.followed_department_fids.include?(crazy_dpt.fid),'followed_department_fids复原'
  end
  it "院系的一阶索引" do
    user_n = User.new
    user_n.save(:validate=>false)
    pl = Department.new
    title = "pppppssssssvvvvvvrrrrrdptdpt#{Department.count+1}"
    pl.name = title
    pl.save(:validate=>false)
    assert Redis::Search.query("Department", title).try(:[],0).try(:[],'id') == pl.id.to_s, '信息齐全后，保存即建立这个院系的一阶索引'
    
    title2 = title.reverse
    assert title2!=title
    pl.update_attribute(:name, title2)
    refute Redis::Search.query("Department", title).try(:[],0).try(:[],'id') == pl.id.to_s, '标题改了，老标题索引不再存在'    
    assert Redis::Search.query("Department", title2).try(:[],0).try(:[],'id') == pl.id.to_s, '标题改了，新标题索引存在'    
    pl.update_attribute(:name, title)
    assert Redis::Search.query("Department", title).try(:[],0).try(:[],'id') == pl.id.to_s, '标题recover'    
    pl.instance_eval(&Department.after_soft_delete)
    refute Redis::Search.query("Department", title).try(:[],0).try(:[],'id') == pl.id.to_s, '软删除之后删除院系的一阶索引'
  end


end
