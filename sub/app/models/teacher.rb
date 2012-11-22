# -*- encoding : utf-8 -*-
require 'net/http'
class Teacher
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    cws = Courseware.where(teachers:self.name).size
    cws < 1
  }
  @after_soft_delete = proc{
    redis_search_index_destroy
    redis_search_psvr_was_delete!
  }

  field :user_id
  field :name
  field :email
  field :slug
  field :bio
  field :tagline
  field :courses_count,:type=>Integer,:default=>0
  field :coursewares_count,:type=>Integer,:default=>0
  field :followers_count, :type => Integer, :default => 0
  field :department_fid
  def self.locate(name)
    Teacher.find_or_create_by(name:name)
  end
  before_save :counter_work
  def counter_work
    if department_fid_changed?
      if department_fid_was
        dep = Department.where(fid:department_fid_was).first
        dep.inc(:teachers_count,-1) if dep
      end
      if department_fid
        dep = Department.where(fid:department_fid).first
        dep.inc(:teachers_count,1) if dep
      end
    end
  end
  def asynchronously_clean_me
    bad_ids = [self.id]
    dep = Department.where(fid:self.department_fid).first
    dep.inc(:teachers_count,-1) if dep
    Course.where(teachers:self.name).each do |t|
      t.teachers.delete(self.name)
      t.teachers_count -= 1
      t.save(:validate=>false)
    end
    Util.bad_id_out_of!(User,:followed_teacher_ids,bad_ids)
  end
  def calculate_department_fid
    # 一般不需要调用
    raw_res = self.coursewares.collect(&:department_fid)
    res = raw_res.uniq.collect{|fid|
      [fid,raw_res.count(fid)]
    }
    self.department_fid = res.sort{|x,y|
      x[1]<=>y[1]
    }.try(:[],-1).try(:[],0)
  end
  # index :follower_ids
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following_teachers, :index => true
  def coursewares
     Courseware.where(:teachers=>self.name)
  end
  def courses
    Course.where(:teachers=>self.name)
  end
  def import_counters
    # 一般不需要调用
    self.coursewares_count = self.coursewares.nondeleted.normal.is_father.count
    self.courses_count = self.courses.count
  end
  field :avatar
  def self.touch(name)
    self.find_or_create_by(name:name)
  end
  cache_consultant :avatar_filename,:from_what => :name
  cache_consultant :user_id,:from_what => :name
  cache_consultant :id,:from_what => :name
  def avatar_filename
    ret = self.avatar.to_s
    if ret
      return ret.split('/')[-1]
    elsif self.email.present?
      gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
      return "http://gravatar.com/avatar/#{gravatar_id}.png"
    else
      return ''
    end
  end
  mount_uploader :avatar, AvatarUploader
  def department_name
    self.department_fid.present? ? Department.get_name(self.department_fid).to_s : ''
  end
  def department_name_changed?
    self.department_fid_changed?
  end
  def department_name_was
    self.department_fid_was.present? ? Department.get_name(self.department_fid_was).to_s : ''
  end
  def redis_search_alias
    [department_name,self.tagline.present? ? self.tagline : nil].compact.join(', ')
  end
  def redis_search_alias_changed?
    self.department_fid_changed? or self.tagline_changed?
  end
  def redis_search_alias_was
    [department_name_was,self.tagline_was.present? ? self.tagline_was : nil].compact.join(', ')
  end
  def avatar_small40                                                                  
    return self.avatar.small32.url                                                     
  end
  def avatar_small40_changed?
    self.avatar_changed?
  end
  def avatar_small40_was
    return self.avatar_was.small32.url                                                 
  end 

  redis_search_index(:title_field => :name,
                     :alias_field => :redis_search_alias,
                     :prefix_index_enable => true,
                     :ext_fields => [:redis_search_alias,:avatar_small40],
                     :score_field => :coursewares_count)
  alias_method :redis_search_index_create_before_psvr,:redis_search_index_create
  alias_method :redis_search_index_need_reindex_before_psvr,:redis_search_index_need_reindex
  def redis_search_psvr_okay?
    !self.soft_deleted? and self.name.present? and self.redis_search_alias.present?
  end
  def redis_search_index_need_reindex
    if !redis_search_psvr_okay?
     redis_search_index_destroy
     redis_search_psvr_was_delete!
     return false
    else
     return (self.deleted_changed? || self.redis_search_index_need_reindex_before_psvr)
    end
  end
  def redis_search_index_create
    self.redis_search_index_create_before_psvr if self.redis_search_psvr_okay?
  end
end
