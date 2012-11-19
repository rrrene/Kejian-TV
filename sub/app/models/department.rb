# -*- encoding : utf-8 -*-
class Department
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    p "#{self.id} before_soft_delete todo"
  }
  # Followers
  field :follower_ids, :type => Array, :default => []
  field :cover
  mount_uploader :cover, CoverUploader
  field :name
  field :fid
  field :sort
  field :followers_count,:type=>Integer,:default=>0
  field :teachers_count,:type=>Integer,:default=>0
  field :courses_count,:type=>Integer,:default=>0
  field :coursewares_count,:type=>Integer,:default=>0
  field :play_lists_count,:type=>Integer,:default=>0
  validates_uniqueness_of :name,:message=>'与已有院系名重复，请尝试其他名'
  cache_consultant :fid,:from_what => :name,:no_callbacks=>true
  cache_consultant :id,:from_what => :name,:no_callbacks=>true
  cache_consultant :name,:from_what => :fid,:no_callbacks=>true
  
  after_create :update_consultant!
  def integrity_op
    self.courses_count = self.courses.count
  end
  def update_consultant!
    $redis_users.hset(self.name,:fid,self.fid)
    $redis_users.hset(self.name,:id,self.id)
  end
  
  def courses
    Course.where(:department=>self.name)
  end
  def self.fid_fill!
    # 一般不执行
    self.asc('created_at').each_with_index do |item,index|
      item.update_attribute(:fid,PreForumForum.find_by_name_and_type("#{item.name}",'group').fid)
    end
  end
  def self.count_fill!
    # 一般不执行
    self.all.each_with_index do |item,index|
      item.update_attribute(:coursewares_count,item.courses.inject(0){|sum,course| sum+course.coursewares_count})
      item.update_attribute(:play_lists_count,item.courses.inject(0){|sum,course| sum+course.play_lists_count})
    end
  end
  def self.reflect_onto_discuz!
    self.asc('created_at').each_with_index do |item,index|
      next if item.fid.present?
      inst = PreForumForum.insert1("#{item.name}",index+1)
      item.update_attribute(:fid,inst.fid)
    end
  end
  # 以下两个方法是给 redis search index 用
  def cover_small
    self.cover.small.url
  end
  def cover_small_changed?
    self.cover_changed?
  end
  def cover_small38
    self.cover.small38.url
  end
  def cover_small38_was
    self.cover_was.small38.url
  end
  def cover_small38_changed?
    self.cover_changed?
  end
  redis_search_index(:title_field => :name,
    :prefix_index_enable => true,
    :ext_fields => [:cover_small38,:fid],
    :score_field => :coursewares_count)
end

