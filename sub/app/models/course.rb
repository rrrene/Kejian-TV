# -*- encoding : utf-8 -*-
class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    if self.fid.present?
      cws = Courseware.where(course_fid:self.fid).size
      cws < 1
    else
      true
    end
  }
  field :department_fid
  def department_ins
    @department = nil if self.department_fid_changed?
    @department ||= Department.where(:fid=>self.department_fid).first
  end
  def calculate_department_fid
    # 一般不需要调用
    self.department_fid=self.department_ins.fid
  end
  def asynchronously_clean_me
    bad_ids = [self.fid]
    dep = Department.where(fid:self.department_fid).first
    dep.inc(:courses_count,-1) if dep
    self.teachers.each do |t|
      tc = Teacher.where(name:t).first
      tc.inc(:courses_count,-1) if tc
    end
    Util.bad_id_out_of!(User,:followed_course_fids,bad_ids)
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
  def gotfid?
    self.fid.try(:>,0) and self.department_fid.try(:>,0)
  end
  scope :gotfid,where(:fid.gt=>0,:department_fid.gt=>0)  
  
  # index :fid
  cache_consultant :name,:from_what => :fid
  cache_consultant :department_fid,:from_what => :fid
  
  embeds_many :teachings
  before_save :dz_op!
  def dz_op!
    if self.name.present? and self.department_fid.present? and self.fid.blank?
      if self.number.present?
        name = "[#{self.number}] #{self.name}"
      else
        name = "#{self.name}"
      end
      if PreForumForum.where(:name=>self.name).first.present?
        inst=PreForumForum.where(:name=>name).first
      else
        ddid=self.department_fid
        raise "department_fid shouldn't be blank" if ddid.blank?
        inst = PreForumForum.insert2(ddid,self.name,Course.count+1)     ###psvr 数据库导入时候有点问题。PreForumForum和线上数据不一致。只到了2000+实际应该是3000+
      end
      self.update_attribute(:fid,inst.fid)
    end
  end 
  before_save :teacher_work
  def teacher_work
    if self.teachers_changed?
      self.teachers_count = self.teachers.size      ##不能用更改dep的方式，因为老师可以跨dep教课
      added = self.teachers - self.teachers_was.to_a
      deled = self.teachers_was.to_a - self.teachers
      added.each do |t|
        tc = Teacher.where(name:t).first
        tc.inc(:courses_count,1) if tc
      end
      deled.each do |t|
        tc = Teacher.where(name:t).first
        tc.inc(:courses_count,-1) if tc
      end
    end
  end
  before_save :department_work
  def department_work
    if self.department_fid_changed?
      dep = Department.where(fid:self.department_fid).first
      dep.inc(:courses_count,1)
      if self.department_fid_was.present?
        dep = Department.where(fiq:department_fid).first
        dep.inc(:courses_count,-1)
      end
    end
  end
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
  alias_method :redis_search_index_create_before_psvr,:redis_search_index_create
  alias_method :redis_search_index_need_reindex_before_psvr,:redis_search_index_need_reindex
  def redis_search_psvr_okay?
    !self.soft_deleted? and self.name_long.present? and self.redis_search_alias.present? and self.gotfid?
  end
  def redis_search_index_need_reindex
    return false if !redis_search_psvr_okay?
    return self.redis_search_index_need_reindex_before_psvr
  end
  def redis_search_index_create
    if self.redis_search_psvr_okay?
      return self.redis_search_index_create_before_psvr
    else
      return true
    end
  end
end

