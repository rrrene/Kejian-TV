# -*- encoding : utf-8 -*-
class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :courseware
  # belongs_to :user
  
  field :title, :type => String
  field :body, :type => String
  field :page, :type => Integer,:default => 0
  field :x, :type => Integer, :default => 0
  field :y, :type => Integer, :default => 0
  field :width, :type => Integer, :default => 0
  field :height, :type => Integer, :default => 0
  field :shared, :type => Integer, :default => 0 # 0 is private; 1 is public;2 is public for followers
  field :user_id
  field :courseware_id
  
  # index :user_id
  # index :courseware_id

  validates_presence_of :body,:page,:x,:y,:width,:height,:shared,:user_id,:courseware_id
  
  def self.human_attribute_name(attr, options = {})
     case attr.to_sym
     when :title
       '笔记标题'
     when :body
       '笔记内容'
     when :shared
       '公开'
     when :user_id
       '做笔记者'
     when :x
       '横坐标'
     when :y
       '纵坐标'
     when :width
       '宽度'
     when :height
       '长度'
     when :page
       '页数'
     else
       attr.to_s
     end
  end

  def shared_public!
    self.shared = 1
    self.save!
  end
  def shared_private!
    self.shared = 0
    self.save!
  end
  def shared_followers
    self.shared = 2
    self.save!
  end
  
end
