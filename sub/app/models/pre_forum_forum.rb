# -*- encoding : utf-8 -*-
class PreForumForum < ActiveRecord::Base
  include ActiveBaseModel
  self.table_name =  'pre_forum_forum'
  # 这个是用来添加一级板块用的
  # name 名字
  # displayorder 显示顺序
  def self.insert1(name,displayorder)
    forum = self.create! do |f|
      f.type='group'
      f.name=name
      f.status=1
      f.displayorder=displayorder
    end
    PreForumForumfield.create! do |x|
      x.fid=forum.id
    end
    forum
  end
  # 这个是用来添加第二级子模块用的
  # up_fid 是父亲板块的fid
  # name 名字
  # displayorder 显示顺序
  def self.insert2(up_fid,name,displayorder)
    forum = self.create! do |x|
      x.fup=up_fid
      x.type='forum'
      x.name=name.to_s
      x.status=1
      x.displayorder=displayorder
      x.styleid=0
      x.allowsmilies=1
      x.allowbbcode=1
      x.allowimgcode=1
      x.allowpostspecial=1
      x.recyclebin=1
      x.allowside=0
      x.allowfeed=0
    end
    PreForumForumfield.create! do |x|
      x.fid=forum.id
      x.threadtypes=''
    end
    forum
  end
  # 这个是用来添加第三级子模块用的
  # up_fid 是父亲板块的fid
  # name 名字
  # displayorder 显示顺序
  def self.insert3(up_fid,name,displayorder)
    forum = self.create! do |x|
      x.fup=up_fid
      x.type='sub'
      x.name=name.to_s
      x.status=1
      x.displayorder=displayorder
      x.styleid=0
      x.allowsmilies=1
      x.allowbbcode=1
      x.allowimgcode=1
      x.allowpostspecial=1
      x.recyclebin=1
      x.allowside=0
      x.allowfeed=0
    end
    PreForumForumfield.create! do |x|
      x.fid=forum.id
      x.threadtypes=''
    end
    forum
  end
  scope :type1,where(:type=>:group)
  scope :type2,where(:type=>:forum)
  scope :type3,where(:type=>:sub)
  def self.inheritance_column
    'inheritance_type'
  end
end
