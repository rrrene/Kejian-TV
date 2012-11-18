# -*- encoding : utf-8 -*-
class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    p "#{self.id} before_soft_delete todo"
  }
  field :department_fid
  def calculate_department_fid
    # 一般不需要调用
    self.department_fid=self.department_ins.fid
  end
  def asynchronously_clean_me
    bad_ids = [self.fid]
    Util.bad_id_out_of!(User,:followed_course_fids,bad_ids)
  end
  field :department
  def department_ins
    @department = nil if self.department_fid_changed?
    @department ||= Department.where(:name=>self.department).first
  end
  field :ctype
  field :number
  field :name
  field :fid
  field :follower_ids, :type => Array, :default => []
  field :followers_count,:type=>Integer,:default=>0
  field :coursewares_count,:type=>Integer,:default=>0
  field :play_lists_count,:type=>Integer,:default=>0
  def teaching_affairs
    # 一般不调用
    self.teachers = self.teachings.collect do |x|
      x.teacher
    end.uniq.compact
    self.teachers_count = self.teachers.count
  end
  field :teachers_count,:type=>Integer,:default=>0
  field :teachers,:type=>Array,:default=>[]
  field :years,:type=>Array,:default=>[]
  
  field :eng_name
  field :credit
  field :credit_hours
  field :jiaoxuefs
  field :neirongjianjie
  field :book1
  field :book2
  
  
  # index :fid
  cache_consultant :name,:from_what => :fid,:no_callbacks=>true
  cache_consultant :department,:from_what => :fid,:no_callbacks=>true
  
  after_create :update_consultant!
  def update_consultant!
    $redis_users.hset(self.fid,:name,self.name)
    $redis_users.hset(self.fid,:department,self.department)
  end
  
  embeds_many :teachings
  
  def self.reflect_onto_discuz!
    self.all.asc('created_at').each_with_index do |item,index|
      next if item.fid.present?
      if item.number.present?
        name = "[#{item.number}] #{item.name}"
      else
        name = "#{item.name}"
      end
      if PreForumForum.where(:name=>name).first.present?
        puts name
        inst=PreForumForum.where(:name=>name).first
      else
        ddid=Department.get_fid(item.department)
        binding.pry if ddid.blank?
        inst = PreForumForum.insert2(ddid,name,index+1)
      end
      item.update_attribute(:fid,inst.fid)
    end
  end
  def self.fid_fill!
    self.asc('number').each_with_index do |item,index|
      ins=PreForumForum.find_by_name("[#{item.number}] #{item.name}")
      item.update_attribute(:fid,ins.nil? ? nil : ins.fid)
    end
  end
  def self.shoudongtianjia!(department,number,name,*teachers)
    item=self.create!(department:department,number:number,name:name)
    f=PreForumForum.insert2(1,"[#{item.number}] #{item.name}",PreForumForum.count+1)
    item.update_attribute(:fid,f.fid)
    Teaching.shoudongtianjia!(item,*teachers)
  end
  def coursewares
    Courseware.where(:course_fid=>self.fid)
  end
  def play_lists
    PlayList.destroyable.where(:course_fid=>self.fid)
  end
  def self.import_coursewares_count
    Course.all.each do |x|
      x.update_attribute(:coursewares_count,x.coursewares.count)
    end
  end
  def self.import_play_lists_count
    Course.all.each do |x|
      x.update_attribute(:play_lists_count,x.play_lists.count)
    end
  end
  def department_name
    self.department_fid.present? ? Department.get_name(self.department_fid).to_s : ''
  end
  def department_name_changed?
    self.department_fid_changed?
  end
  def department_name_was
    self.department_fid_was.present? ? Department.get_name(self.department_fid_was).to_s : ''
  end
  def name_long
    self.number ? "[#{self.number}] #{self.name}" : self.name
  end
  def name_long_changed?
    self.number_changed? or self.name_changed?
  end
  def name_long_was
    self.number_was ? "#{self.number_was} #{self.name_was}" : self.name_was
  end
  def redis_search_alias
    [self.department_name,self.teachers.join(', ')].join(', ')
  end
  def redis_search_alias_changed?
    self.teachers_changed? or self.department_fid_changed? or self.name_long_changed?
  end
  def redis_search_alias_was
    [self.department_name_was,self.teachers_was.join(', ')].join(', ')
  end
  redis_search_index(:title_field => :name_long,
                     :alias_field => :redis_search_alias,
                     :prefix_index_enable => true,
                     :ext_fields => [:fid,:department_name,:ctype,:teachers],
                     :score_field => :coursewares_count)
end

