# -*- encoding : utf-8 -*-
require 'test_helper'
describe Course do
  it "当一个课件添加到一个课程的时候，这个课程的课件总计数应该做出相应改变" do
    c = Courseware.new
    cc = Course.first
    c.course_fid = cc.fid
    cc_coursewares_count = cc.coursewares_count
    c.save(:validate=>false)
    cc.reload
    assert cc.coursewares_count == cc_coursewares_count + 1,"当一个课件添加到一个课程的时候，这个课程的课件总计数应+1"
    ccc = Course.where(:fid.ne=>cc.fid).first
    c.course_fid = ccc.fid
    ccc_coursewares_count =ccc.coursewares_count
    c.save(:validate=>false)
    ccc.reload
    cc.reload
    assert cc.coursewares_count == cc_coursewares_count,"课件的课程被修改了，那么原来老的课程的课件总计数恢复"
    assert ccc.coursewares_count == ccc_coursewares_count +1,"课件的课程被修改了，新的课程的课件计数+1"
  end
end