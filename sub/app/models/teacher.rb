# -*- encoding : utf-8 -*-
require 'net/http'
class Teacher
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    p "#{self.id} before_soft_delete todo"
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
  after_save{
    self.class.set_id(self.name,self.id)
  }
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
end
