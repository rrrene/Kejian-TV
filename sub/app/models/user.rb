# -*- encoding : utf-8 -*-
require 'net/http'
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongo::Voter
  include Redis::Search
  include BaseModel
  after_update :after_update_uc
  def after_update_uc
    if self.encrypted_password_changed?
      UCenter::User.update(nil,{username:self.slug,newpw:self.password,email:self.email,ignoreoldpw:true})
    end
  end
  has_many :coursewares
  embeds_one :sub_user_material
  before_validation :fill_in_unknown_email,:unless=>'during_registration'
  before_validation :fill_in_unknown_name,:unless=>'during_registration'
  def self.get_credits(uid)
    ret = $redis_users.hget(uid,:credits)
    if ret.nil?
      item = PreCommonMember.where(uid:uid.to_i).first
      return 0 if item.nil?
      ret = item.credits
      self.set_credits(uid,ret)
    end
    ret 
  end
  def self.set_credits(uid,val)
    $redis_users.hset(uid,:credits,val)
  end

  def getauth(provider_name=nil)
    h={uc_uid:self.uid}
    if provider_name.present?
      h[:provider]=provider_name.to_s 
    else
      h[:get_all]='1'
    end

    UCenter::ThirdPartyAuth.getauth(nil,h)
  end
  def getauth!(provider_name)
    UCenter::ThirdPartyAuth.getauth(nil,{uc_uid:self.uid,provider:provider_name.to_s,will_create:1})
  end
  
  field :renren_cookies
  #这个字段呢，是用来标注用户是不是来自传统的email注册方式
  field :during_registration
  #下面这个字段呢，是用来标记注册到第几步了。完成注册这个值为1000，所以嘛，如果这个值小于1000，那就跳转用户到相应的注册步骤咯
  field :reg_extent,:type=>Integer,:default=>0
  def reg_extent_okay?
    self.reg_extent.try(:>=,1000)
  end
  EXTENT_TEXT = {
    0 => '请登录您的人人账号',
    1 => '正在准备读取数据',
    2 => '正在读取资料',
    3 => '正在从公共主页切换回来',
    4 => '正在绑定账号',
    5 => '正在获取主页',
    6 => '正在发表绑定成功状态',
    7 => '正在关注课件交流系统公共主页',
    8 => '正在导入资料',
    9 => '正在导入好友',
    10 => '正在导入头像',
  }

  FORBIDDEN_FANGWENDIZHI = %w{
    api
    user_logged_in_required
    modern_required
    mine
    account
    users
    register
    login
    login_ibeike
    logout
    all_unread_notification_num
    ajax
    presentations
    hack
    welcome
    play_lists
    departments
    courses
    schools
    maps
    un_courses
    coursewares_by_departments
    coursewares_by_teachers
    coursewares_by_courses
    coursewares_with_page
    coursewares_mine
    coursewares
    embed
    users
    mobile
    under_verification
    frozen_page
    refresh_sugg
    refresh_sugg_ex
    bugtrack
    agreement
    traverse
    home
    nb
    home
    root
    topics_follow
    topics_unfollow
    zero_asks
    mobile
    uploads
    upload
    edit
    delete
    update
    upgrade
    update_in_place
    newbie
    followed
    recommended
    mark_all_notifies_as_read
    mark_notifies_as_read
    mute_suggest_item
    report
    doing
    teachers
    users
    autocomplete
    search
    asks
    answers
    comments
    topics
    logs
    inbox
    cpanel
    sidekiq
    popup
    preminum
    biz
    business
  }.uniq
  def completion_rate
    if !self.valid?
      return 0
    else
      return 10
    end
  end
  def self.expert_with_topic(opts={})
    opts[:without]||=[Setting.zuozheqingqiu_id]
    ret = []
    users = User.where(:expert_topic.ne=>nil,:_id.nin=>opts[:without]) #todo: .where(:confirmed_at.ne=>nil)
    (0..users.count-1).sort_by{rand}.slice(0, 4).each do |i|
      u = users.skip(i).first
      t = Topic.locate u.expert_topic
      ret << [t,u]
    end
    ret
  end
  def self.shoudongtianjia!(name,email,password)
    u=self.new
    u.name=name
    u.email=email
    u.password=password
    u.password_confirmation=password
    u.save!
  end
  def fill_in_unknown_password
    if self.encrypted_password.blank?
      password = "#{Time.now.to_i}_#{rand}"
      self.password = password
      self.password_confirmation = password
    end
    true
  end
  def fill_in_unknown_email
    if self.email.blank?
      self.email_unknown = true
      self.skip_reconfirmation!
      self.email = "unknown#{Time.now.to_i}#{rand}@example.com"
    else
      unless self.email=~/^unknown.*@example\.com/
        self.email_unknown = false
      end
    end
    true
  end
  def fill_in_unknown_name
    if self.name.blank?
      self.name_unknown = true
      self.name = "姓名请求"
    else
      self.name_unknown = false
    end
    true
  end
  before_validation :english_nameize
  def english_nameize
    if new_record? or name_changed?
      if self.name.present? and !self.name_unknown
        str = Pinyin.t(self.name,' ').titleize
        strs = str.split(' ')
        family_name = strs.shift
        given_name = strs.join('').downcase.camelize
        self.name_en = "#{given_name} #{family_name}"
      end
    end
  end
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable,
         :lockable, :timeoutable, :omniauthable#, :invitable
  # P.S.V.R性能改善点，去掉validatable，防止['users'].find({:email=>"efafwfdlkjfdlsjl@qq.com"}).limit(-1).sort([[:_id, :asc]])查询
  ## Database authenticatable
  field :uid,:type=>Integer #UCenter
  field :ibeike_uid #UCenter of iBeiKe
  field :ibeike_slug #UCenter of iBeiKe
  field :discuz_pw #DZ
  field :reputation,:type=>Integer,:default=>0
  field :regip
  field :email_unknown,:type=>Boolean,:default=>false
  field :is_expert,:type=>Boolean,:default=>false
  field :name_unknown,:type=>Boolean,:default=>false
  field :expert_topic #calculated by TopicSuggestExpert
  field :expert_topic_score, :type => Integer, :default => 0 #calculated by TopicSuggestExpert
  has_and_belongs_to_many :following, :class_name => 'User', :inverse_of => :followers, :index => true
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following, :index => true
  has_and_belongs_to_many :followed_asks, :inverse_of => :followers, :class_name => "Ask"
  has_and_belongs_to_many :followed_topics, :inverse_of => :followers, :class_name => "Topic"
  # field :followed_ask_ids, :type => Array, :default => []
  # field :followed_topic_ids, :type => Array, :default => []
  # field :following_ids, :type => Array, :default => []
  # field :follower_ids, :type => Array, :default => []
  field :answered_ask_ids, :type => Array, :default => []
  field :followed_ask_ids, :type => Array, :default => []
  field :followed_department_fids, :type => Array, :default => []
  field :followed_teacher_ids,:type=>Array,:default => []
  field :followed_course_fids,:type=>Array,:default => []
  field :inviter_ids,:type=>Array,:default => []
  field :inviter_invited_at,:type=>Hash,:default => {}
  def invite_by(user,immediately=true)
    self.follow(user)
    user.follow(self)
    if immediately
      self.devise_mailer.invitation_instructions(self.id,user.id).deliver
      self.inviter_invited_at[user.id.to_s] = Time.now
    end
    self.inviter_ids << user.id unless self.inviter_ids.include?(user.id)
    self.save(:validate=>false)
  end
  field :email,              :type => String, :default => ""
  # index :email, :uniq => true
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  # enable function
  field :mark_history,       :type => Boolean, :default => true
  field :mark_search_keyword,:type => Boolean, :default => true
  field :enable_beauty_view, :type => Boolean, :default => false
  field :widget_sort,        :type => Hash,    :default => {'left' => ['1','2'],'right' => ['3','4']}
  field :widget_property,    :type => Hash,    :default => {kejians:['课件','4',''],comments:['评论','4'],analytics:['过去 30 天的主要统计信息'],promos:['新增内容']}
=begin
widget_property 
kejians:['课件','num','filter'],comments:['评论','num']

=end
  def update_widget_kejian(title,num,filter)
    if title.blank?
      title = self.widget_property['kejians'][0]
    end
    self.widget_property['kejians'] = [title,num,filter]
    re = self.save(:validate=>false)
    return re
  end
  def update_widget_commment(title,num)
    if title.blank?
      title = self.widget_property['kejians'][0]
    end
    self.widget_property['comments'] = [title,num]
    re = self.save(:validate=>false)
    return re
  end
  ## Comment 
  field :last_comment_at,    :type =>Time

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String
  
  @before_soft_delete = proc{
    redis_search_index_destroy
    $redis_users.hdel self.uid,:id
    $redis_users.hdel self.id,:name
    $redis_users.hdel self.id,:uid
    $redis_users.hdel self.id,:email
    $redis_users.hdel self.id,:slug
    # $redis_users.hdel self.id,:fangwendizhi
    $redis_users.hdel self.id,:avatar_filename
  }
  @after_soft_delete = proc{
    self.update_attribute(:banished,"1")
    self.update_attribute(:user_type,User::BAN_USER)
  }
  def asynchronously_clean_me
    bad_ids = [self.id]
    Util.bad_id_out_of!(AskInvite,:invitor_ids,bad_ids)
    Util.bad_id_out_of!(Topic,:follower_ids,bad_ids)
    Util.bad_id_out_of!(Ask,:spam_voter_ids,bad_ids)
    Util.bad_id_out_of!(Ask,:to_user_ids,bad_ids)
    Util.bad_id_out_of!(Ask,:follower_ids,bad_ids)
    Util.bad_id_out_of!(User,:follower_ids,bad_ids)
    Util.bad_id_out_of!(User,:following_ids,bad_ids)
    Util.bad_id_out_of!(Courseware,:thanked_user_ids,bad_ids)
    Util.bad_id_out_of!(Courseware,:disliked_user_ids,bad_ids)
    Util.bad_id_out_of!(PlayList,:disliked_user_ids,bad_ids)
    Util.bad_id_out_of!(PlayList,:liked_user_ids,bad_ids)
    Util.del_propogate_to(Comment,:user_id,bad_ids)
    Util.del_propogate_to(AskInvite,:user_id,bad_ids)
    Util.del_propogate_to(Notification,:user_id,bad_ids)
    Util.del_propogate_to(Answer,:user_id,bad_ids)
    Util.del_propogate_to(Ask,:to_user_id,bad_ids)
    Util.del_propogate_to(Ask,:user_id,bad_ids)
    Util.del_propogate_to(Courseware,:user_id,bad_ids)
    Util.del_propogate_to(PlayList,:user_id,bad_ids)
    # vote_up_count
    
    Answer.where("votes.up"=>self.id).each do |ans|
      ans.votes['up'].delete self.id
      ans.save
      ans.inc(:vote_up_count,-1)
    end
    Answer.where("votes.down"=>self.id).each do |ans|
      ans.votes['down'].delete self.id
      ans.save
      ans.inc(:vote_down_count,-1)
    end
    Deferred.where(:user_id=>self.id).each do |d|
      d.delete
    end
    # vote_down_count
    self.logs.each do |c|
      Notification.where(:log_id=>c._id).each do |n|
        n.update_attribute(:deleted,1)
      end
      c.delete
    end
    self.update_attribute(:banished,"1")
    # ------------------------
    self.followers.each{|u| u.inc(:following_count,-1)}
    self.following.each{|u| u.inc(:followers_count,-1)}
    self.thanked_answers.each{|an| an.inc(:thanked_count,-1)}
    self.thanked_coursewares.each{|an| an.inc(:thanked_count,-1)}
    self.thanked_play_list_ids.each{|an| an.inc(:vote_up,-1)}
    self.followed_asks.each{|ask| ask.inc(:followed_count,-1)}
  end
  #user_type
  NORMAL_USER=1
  EXPERT_USER=2
  ELITE_USER=3
  FROZEN_USER=4
  BAN_USER=5
  USER_TYPE={User::NORMAL_USER=>"普通用户",User::EXPERT_USER=>"问道专家",User::ELITE_USER=>"问道精英",User::FROZEN_USER=>"冻结用户",User::BAN_USER=>"屏蔽用户"}
  #admin_type
  NO_ADMIN=1
  SUP_ADMIN=2
  SUB_ADMIN=3
  ADMIN_TYPE={User::NO_ADMIN=>"",User::SUP_ADMIN=>"管理员",User::SUB_ADMIN=>"副管理员"}
  has_many :oauth_accesses
  # the way to set admins:
  #   user.update_attribute(:admin_type,User::SUP_ADMIN)
  def self.admins
    User.where(:user_type.in=>[User::SUB_ADMIN,User::SUP_ADMIN])
  end
  def super_admin?
    Setting.admin_emails.include? self.email
  end
  def admin?
    self.admin_type==User::SUB_ADMIN or self.admin_type==User::SUP_ADMIN
  end
  def uri
    "http://#{Setting.domain}/users/#{self.slug}"
  end
  # todo: temporarily disable----------------------------------------------
  # cache_consultant :fangwendizhi,:no_callbacks=>true
  def User.get_fangwendizhi(id)
    return "users/#{id}"
  end
  def User.set_fangwendizhi(*args)
  end
  def fangwendizhi
    return "users/#{self.id}"
  end
  # todo: temporarily disable----------------------------------------------  
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :tagline
      '一句话介绍'
    when :slug
      '用户名'
    when :fangwendizhi
      '访问地址后缀'
    when :inviting;'立即发送邀请'
    when :website;'个人网站'
    when :location;'所在地'
    when :company;'公司'
    when :available_for_hire;'是否接受雇主联系'
    when :bio;'个人简介'
    when :department;'用户所属院系'
    when :school;'用户所属学校'
    when :email_human;'电子邮箱'
    when :slug;'用户的个性域名'
    when :password;'密码'
    when :password_confirmation;'密码确认'
    when :remember_me;'记住我的登录状态'
    when :name;'真实姓名'
    when :encrypted_password;'加密后密码'
    when :reset_password_token;'重置密码链接字符串'
    when :reset_password_sent_at;'重置密码链接字符串发送时间'
    when :remember_created_at;'记住我的登录状态创建时间'
    when :sign_in_count;'累计登录次数'
    when :current_sign_in_at;'本次登录于时间'
    when :last_sign_in_at;'上次登录时间'
    when :current_sign_in_ip;'本次登录IP'
    when :last_sign_in_ip;'上次登录IP'
    when :confirmation_token;'验证链接字符串'
    when :confirmed_at;'验证于时间'
    when :confirmation_sent_at;'验证链接发送于时间'
    when :unconfirmed_email;'待验证电子邮箱'
    when :failed_attempts;'失败登录尝试次数'
    when :unlock_token;'解锁链接字符串'
    when :locked_at;'锁定于时间'
    when :authentication_token;'认证字符串'
    when :email_unknown;'是否邮箱请求'
    when :name_unknown;'是否姓名请求'
    when :coursewares_count;'发布课件数'
    when :courseware_series_count;'发布课件系列数'
    when :hits_count;'资料被阅数'
    when :name_en;'英文名'
    when :lingyu;'所属行业或学术领域'
    when :avatar;'头像'
    when :tagline;'一句话简介'
    when :autotagline;'自动一句话简介'
    when :name_pinyin;'姓名拼音'
    when :thanked_count;'被感谢次数'
    when :banished;'是否被禁'
    when :born_at;'生日'
    when :died_at;'卒于'
    else
      COMMON_HUMAN_ATTR_NAME[attr].present? ? COMMON_HUMAN_ATTR_NAME[attr] : attr.to_s
    end
  end
  
  # has_many :clients
  # has_many :tokens, :class_name => "OauthToken"#, :order => "authorized_at desc", :include => [:client_application]
  field :current_mails
  
  field :user_type, :type => Integer, :default => User::NORMAL_USER
  field :admin_type, :type => Integer, :default => User::NO_ADMIN
  field :admin_area, :type => Array, :default => []
  field :created_from_mobile, :type => Integer, :default=>0
  field :name
  def name_beautified
    @name_beautified ||= ('_'==name[0] ? name[1..-1] : name)
  end
  def title
    self.name
  end
  def create_playlists_for_user
      x=PlayList.find_or_create_by(user_id:self.id,title:'收藏')
      y=PlayList.find_or_create_by(user_id:self.id,title:'稍后阅读')
      z=PlayList.find_or_create_by(user_id:self.id,title:'历史记录')
      x.update_attribute(:undestroyable,true)
      y.update_attribute(:undestroyable,true)
      z.update_attribute(:undestroyable,true)
  end
  field :slug
  # field :fangwendizhi
  # sanitizing fangwendizhi
=begin
  def self.fangwendizhize(str)
    str.gsub!('_','-')
    while '_'==str[0]
      str=str[1..-1]
    end
    while '-'==str[0]
      str=str[1..-1]
    end
    str=str.split('.').join('-')
    str.gsub!(/[^\w\-]/,'')
    while str.match('--')
      str.gsub!('--','-')
    end
    while '_'==str[0]
      str=str[1..-1]
    end
    while '-'==str[0]
      str=str[1..-1]
    end
    str.downcase.xi
  end
  def import_fangwendizhi
    str = UCenter::User.get_fangwendizhi(nil,{uid:self.uid.to_s})
    if str.present?
      return str
    else
      return nil
    end
  end
  def try_settting_fangwendizhi
    raise 'no uid!!!' if self.uid.blank?
    if self.zhenshixingming?
      if self.name_en.present?
        str = self.name_en.parameterize
      else
        str = Pinyin.t(self.name,'-')
      end
    else
      str = Pinyin.t(self.name,'-')
    end
    str = User.fangwendizhize(str)
    if str.present?
      ret = UCenter::User.update_fangwendizhi(nil,{will_fire:true,fangwendizhi:str,uid:self.uid.to_s})
      if('1'==ret)
        self.fangwendizhi=str
        return true
      end
    end
    str = self.email.split('@')[0]
    str = User.fangwendizhize(str)
    if str.present? and !str.starts_with?('unknown')
      ret = UCenter::User.update_fangwendizhi(nil,{will_fire:true,fangwendizhi:str,uid:self.uid.to_s})
      if('1'==ret)
        self.fangwendizhi=str
        return true
      end
    end
    str="_#{self.uid}"
    ret = UCenter::User.update_fangwendizhi(nil,{will_fire:true,fangwendizhi:str,uid:self.uid.to_s})
    if('1'!=ret)
      raise 'last resort failed!'
    end
    self.fangwendizhi=str
  end
=end
  field :tagline
  field :tagline_changed_at
  field :avatar_changed_at, :type => Time
  field :last_login_at, :type => Time
  field :login_times, :type => Integer, :default => 0
  field :will_autofollow,:type=>Boolean,:default=>false
  field :bio
  field :location
  field :email_unknown,:type=>Boolean,:default=>false
  field :name_unknown,:type=>Boolean,:default=>false
  field :name_pinyin
  field :name_en
  field :school
  field :lingyu #领域
  field :lingyu_industry
  field :lingyu_study
  field :department
  field :died_at, :type => Date

  before_save Proc.new{
    if self.tagline_changed?
      self.tagline_changed_at = Time.now
    end
  }
  before_save :downcase_email
  def downcase_email
    self.email.downcase!
  end
  before_save :counter_work
  def counter_work
    self.followers_count = self.follower_ids.count if self.follower_ids
    self.following_count = self.following_ids.count if self.following_ids
    self.coursewares_count = Courseware.where(:user_id=>self.id).count
    self.coursewares_uploaded_count = Courseware.where(:uploader_id=>self.id).count
    if new_record?
    end
  end
  
  def state
    if self.name_unknown
      {:name => STATE_TEXT[:name_unknown],:css => :error}
    elsif self.banished
      {:name => STATE_TEXT[:banished],:css => :nothing}
    elsif !!self.died_at
      {:name => STATE_TEXT[:dead],:css => :nothing}
    elsif self.email_unknown
      {:name => STATE_TEXT[:email_unknown],:css => :warn}
    elsif !self.confirmed?
      {:name => STATE_TEXT[:nonconfirmed],:css => :black_white}
    else #if self.valid?
      {:name => STATE_TEXT[:normal],:css => :ok}
    # else
    #   {:name => '奇异状态',:css => :error}
    end
  end

  STATE_TEXT = {
    :name_unknown => '姓名请求',
    :email_unknown => '邮箱请求',
    :nonconfirmed => '等待邮件确认',
    :banished => '已被禁',
    :dead => '已过世',
    :normal => '正常'
  }
  # 是否允许登录
  def active_for_authentication?
    return true
    # self.authorizations.count>0 or (self.encrypted_password.present? && self.banished!='1' && !access_locked? && died_at.blank? && confirmed?)
  end
  def jiaxingming?
    return self.name =~ /^_/
  end
  def zhenshixingming?
    return self.name =~ /^[^_]/
  end
  scope :jiaxingming,where(:name=>/^_/) # 假姓名
  scope :zhenshixingming,where(:name=>/^[^_]/) # 真实姓名
  scope :normal,where(:uid.gt=>0)
  scope :already_confirmed,where(:confirmed_at.ne => nil)
  scope :name_unknown, where(:name_unknown => true)
  scope :email_unknown, where(:email_unknown => true)
  scope :nonconfirmed, where(:confirmed_at => nil)
  scope :dead, where('died_at != NULL')
  scope :banished, where(:banished => '1')
  # validations----------------------------------------------------------------------
  validate :vali_name_check, :if => :name_required?
  def vali_name_check
    if self.name_changed?
      if self.name.blank?
        errors.add(:name,"不能留空")
        return false      
      end
      unless self.name.starts_with?('_')
        if Ktv::Utils.js_strlen(self.name)>12
         errors.add(:name,"不能多于6个汉字或者12个字符")
         return false
        end
        if Ktv::Utils.js_chinese(self.name)<2
         errors.add(:name,"貌似不是真实的：）")
         return false
        end
        if !Ktv::Renren.name_okay?(self.name)
         errors.add(:name,"不是合法的中文姓名<br><span style=\"font-size:12px\">(若不愿透露姓名，请输入一个下划线开头的名字以跳过此测试)</span>")
         return false
        end
      end
    end
  end
  # validate :vali_lingyu_check
  def vali_lingyu_check
    if self.lingyu_industry.blank? and self.lingyu_study.blank?
      errors.add(:lingyu, '请至少选择一项')
    end
  end
  validate :bio_lengthvali
  def bio_plain
    Nokogiri.HTML(self.bio).text()
  end
  def bio_lengthvali
    errors.add(:bio, '太长') unless self.bio_plain.length <= 4000
  end
  field :at_province
  field :at_city
  field :at_dist
  field :at_community
  field :addr
  validates_length_of :tagline,:maximum=>40
  validates_presence_of :slug
=begin
  validate :vali_fangwendizhi
  def vali_fangwendizhi
    if self.fangwendizhi_changed?
      self.fangwendizhi = User.fangwendizhize(self.fangwendizhi)
      not_used = true
      not_used = (!User::FORBIDDEN_FANGWENDIZHI.include?(self.fangwendizhi)) if not_used
      not_used = ('0'==UCenter::User.update_fangwendizhi(nil,{will_fire:false,fangwendizhi:self.fangwendizhi,uid:self.uid.to_s})) if not_used
      if(!not_used)
        errors.add(:fangwendizhi, '已被占用')
      else
        ret = UCenter::User.update_fangwendizhi(nil,{will_fire:true,fangwendizhi:self.fangwendizhi,uid:self.uid.to_s})
        if('1'!=ret)
          raise 'fangwendizhi update failed!'
        end
      end
    end
  end
=end
  # validate :location_vali
  def location_vali
    self.location = ''
    if self.at_province.present? and self.at_province[0]!='-'
      self.location += self.at_province
      if self.at_city.present? and self.at_city[0]!='-'
        self.location += at_city
        if self.at_dist.present? and self.at_dist[0]!='-'
          self.location += at_dist
          if self.at_community.present? and self.at_community[0]!='-'
            self.location += at_community
          end
        end
      end
    end
    if self.location.blank?
      errors.add(:location, '不能为空')
    end
  end
  validates_uniqueness_of :slug,:message=>'与已有个性域名重复，请尝试其他域名'
  validates_format_of :slug, :with => /[a-z0-9\-\_]{1,20}/i
  validate :name_change_not_too_often
  validate :u_center_email_uniq, :if => 'email_changed? && errors[:email].blank?'
  validate :u_center_slug_uniq, :if => 'slug_changed? && errors[:slug].blank?'
  def u_center_email_uniq
    u = UCenter::User.get_user(nil,{username:self.email,isemail:1})
    errors.add(:email,"已经被使用") unless '0'==u
  end
  def u_center_slug_uniq
    unless self.new_record?
      #todo
      errors.add(:slug,"暂时不能修改（开发中,sorry）")
      return false
    end
    u = UCenter::User.get_user(nil,{username:self.slug})
    errors.add(:slug,"已经被使用") unless '0'==u
  end
  # 用户修改昵称，一个月只能修改一次
  def name_change_not_too_often
    unless self.new_record?
      if self.name_changed?
        if self.name_last_changed_at and self.name_last_changed_at > 1.months.ago
          errors[:name] << "一个月只能修改一次"
          return false
        else
          self.name_last_changed_at = Time.now
          return true
        end
      end
    end
  end
  attr_accessor :force_confirmation_instructions
  alias_method :send_on_create_confirmation_instructions_before_psvr,:send_on_create_confirmation_instructions
  alias_method :send_confirmation_instructions_before_psvr,:send_confirmation_instructions
  def send_on_create_confirmation_instructions
    unless self.email_unknown or self.name_unknown
      if self.during_registration or self.force_confirmation_instructions
        self.devise_mailer.confirmation_instructions(self).deliver
      end
    end
  end
  def send_confirmation_instructions
    unless self.email_unknown or self.name_unknown
      send_confirmation_instructions_before_psvr
    end
  end
  def name_required?
    !self.name_unknown
  end
  # ----------------------------------------------------------------------------------
  
  
  field :avatar
  field :website
  # 是否是女人
  field :girl, :type => Boolean, :default => false

  # 是否是可信用户，可信用户有更多修改权限
  field :credible, :type => Boolean, :default => false

  # 不感兴趣的题
  field :muted_ask_ids, :type => Array, :default => []
  field :muted_expert_ids, :type => Array, :default => []
  field :muted_user_ids, :type => Array, :default => []
  field :muted_topics, :type => Array, :default => []
  # Email 提醒的状态
  field :mail_be_followed, :type => Boolean, :default => true
  field :mail_new_answer, :type => Boolean, :default => true
  field :mail_invite_to_ask, :type => Boolean, :default => true
  field :mail_ask_me, :type => Boolean, :default => true
  field :thanked_answer_ids, :type => Array, :default => []
  field :thanked_courseware_ids, :type => Array, :default => []
  field :thanked_play_list_ids, :type => Array, :default => []
  def thanked_answers
    Answer.where(:_id.in=>self.thanked_answer_ids)
  end
  def thanked_coursewares
    Answer.where(:_id.in=>self.thanked_courseware_ids)
  end

  # 邀请字段
  field :invitation_token
  field :invitation_sent_at, :type => Time


  has_many :asks
  has_many :comments
  
  field :profile_view_count,  :type => Integer, :default => 0  
  
  field :sum_cw_views_count, :type => Integer, :default => 0  
  field :asks_count, :type => Integer, :default => 0  
  field :answers_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :followers_count, :type => Integer, :default => 0
  field :following_count, :type => Integer, :default => 0
  field :vote_up_count, :type => Integer, :default => 0
  field :vote_down_count, :type => Integer, :default => 0
  field :share_count, :type => Integer, :default => 0
  field :invite_count, :type => Integer, :default => 0
  field :invited_count, :type => Integer, :default => 0
  field :thank_count, :type => Integer, :default => 0                   # => 课件被其他用户感谢的次数
  field :dislike_coursewares_count, :type => Integer, :default => 0     # => 课件被其他用户不喜欢的次数
  
  field :thanked_count, :type => Integer, :default => 0                 # => 被该self用户感谢的课件数量
  field :disliked_coursewares_count, :type => Integer, :default => 0    # => 被该self用户不喜欢的课件数量
  
  field :coursewares_count, :type => Integer, :default => 0
  field :coursewares_uploaded_count, :type => Integer, :default => 0
  field :level, :type => Integer, :default => 0
  def level_name
    #todo
    '1级'
  end
  has_many :answers
  has_many :notifications
  has_many :inboxes
  field :banished

  def following_names
    self.following_ids.collect{|id| User.find(id).name}
  end

  # index :created_at
  # index :is_expert
  # index :followed_ask_ids
  # index :followed_topic_ids
  # index :slug, :uniq => true
  # index :follower_ids
  # index :following_ids
  # index :name
  # index :tags
  # index :asks_count
  # index :answers_count
  # index :comments_count
  # index :followers_count
  # index :login_times
  # index :last_login_at
  # index :avatar_changed_at
  # index :avatar_filename

  has_many :logs, :class_name => "Log", :foreign_key => "target_id",dependent: :destroy
  
  attr_accessor  :password_confirmation
  # attr_accessor :tags_array
  def tags_array=(str)
    self.tags = str.split(',').collect{|str|str.strip}
  end
  
  def tags_array
    if self.tags
      self.tags.join(',')
    else
      ''
    end
  end
  def avatar_filename
    return ''
    # dzurl = "http://uc.#{Setting.ktv_domain}/avatar.php?uid=#{user.uid}&size=#{size.to_s.split(/\d/).first}"
    # http = Curl.head(dzurl)
    # dz_avatar_url=http.header_str.split("Location: ")[-1].split("\r\n")[0]
    # if dz_avatar_url.ends_with?('/noavatar_small.gif')
    #   s=AvatarUploader::SIZES[size]
    #   gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    #   url = "http://gravatar.com/avatar/#{gravatar_id}.png?r=PG&s=#{s}&default=monsterid"
    # else
    #   return dz_avatar_url
    # end
  end
  field :tags
  field :tags_dpt
  field :name_last_changed_at
  def redis_search_alias
    [self.tagline.present? ? self.tagline : nil].compact.join(', ')
  end
  def redis_search_alias_changed?
    self.tagline_changed?
  end
  def redis_search_alias_was
    [self.tagline_was.present? ? self.tagline_was : nil].compact.join(', ')
  end
  redis_search_index(:title_field => :name,
                     :alias_field => :redis_search_alias,
                     :prefix_index_enable => true,
                     :ext_fields => [:uid,:tagline,:followers_count,:following_count,:coursewares_uploaded_count],
                     :score_field => :followers_count)
  

  def zancheng_piaoshu
    self.answers.inject(0) do |memo,obj|
      num = obj.votes['up_count']
      if num.nil?
        memo
      else
        memo + num
      end
    end
  end
  
  def search_score
    ret = 0
    ret += [80, coursewares_count].min * zancheng_piaoshu
    ret
  end
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("tagline")
      return false
    end
    if self.spam?("name")
      return false
    end
    if self.spam?("slug")
      return false
    end
    if self.spam?("bio")
      return false
    end
  end

  
  mount_uploader :avatar, AvatarUploader

  def self.create_from_hash(auth)  
		user = User.new
		user.name = auth["user_info"]["name"]  
		user.email = auth['user_info']['email']
    if user.email.blank?
      user.errors.add("Email","三方网站没有提供你的Email信息，无法直接注册。")
      return user
    end
		user.save
		user
  end  

  before_validation :auto_slug,:if=>'self.slug.blank?'
  # 此方法用于处理开始注册是自动生成 slug, 因为没表单,只能自动
  def auto_slug
    if self.slug.blank?
      if !self.email.blank?

        self.slug = self.email.split('@')[0]
        self.slug = self.slug.split('.').join('-')
        self.slug += Time.now.to_i.to_s if self.slug.length<1
        self.slug = self.slug[0..27] if self.slug.size>28
        self.slug = self.slug.safe_slug
      end
      if self.name_en.present?
        self.slug = self.name_en.parameterize
        self.slug = self.slug.split('.').join('-')
        self.slug += Time.now.to_i.to_s if self.slug.length<1
        self.slug = self.slug[0..27] if self.slug.size>28
        self.slug = self.slug.safe_slug
      end
      # 如果 slug 被 safe_slug 后是空的,就用 id 代替
      if self.slug.blank?
        self.slug = self.id.to_s
      end
    else
      self.slug = self.slug.safe_slug
    end

    self.slug = self.slug[0..27] if self.slug.size>28
    # 防止重复 slug
    
    while true
      info0 = UCenter::User.get_user(nil,{username:self.slug})
      if '0'!=info0 and info0[0] != self.uid.to_s
        self.slug = rand.to_s.split('0.')[-1]
        self.slug = self.slug[0..27] if self.slug.size>28
      else
        break
      end
    end
  end


  def self.find_by_uid(uid)
    ret = where({:uid => uid.to_i}).first
    if ret.nil?
      info0 = UCenter::User.get_user(nil,{username:uid,isuid:true})
      if '0'!=info0
        u = import_from_dz!(info0)
        return u
      else
        return nil
      end
    else
      return ret
    end
  end
  def self.find_by_slug(slug)
    ret = where({:slug => slug}).first
    if ret.nil?
      info0 = UCenter::User.get_user(nil,{username:slug})
      if '0'!=info0
        u = import_from_dz!(info0)
        return u
      else
        return nil
      end
    else
      return ret
    end
  end
  def self.find_by_email(email)
    ret = User.where({:email => email}).first
    if ret.nil?
      info0 = UCenter::User.get_user(nil,{username:email,isemail:1})
      if '0'!=info0
        u = import_from_dz!(info0)
        return u
      else
        return nil
      end
    else
      return ret
    end
  end

  # 不感兴趣题
  def ask_muted?(ask_id)
    self.muted_ask_ids.include?(ask_id)
  end
  
  def ask_followed?(ask)
    return false if ask.blank?
    if ask.respond_to?(:id)
      self.followed_ask_ids.include?(ask.id)
    else
      self.followed_ask_ids.include?(ask)
    end
  end
  
  def followed?(user)
    return false if user.blank?
    if user.respond_to?(:id)
      self.following_ids.include?(user.id)
    else
      self.following_ids.include?(user)
    end
  end
  def followed_by?(user)
    return false if user.blank?
    if user.respond_to?(:id)
      self.follower_ids.include?(user.id)
    else
      self.follower_ids.include?(user)
    end
  end
  
  def course_followed?(topic)
    return false if topic.blank?
    if topic.respond_to?(:fid)
      self.followed_course_fids.include?(topic.fid)
    else
      self.followed_course_fids.include?(topic)
    end
  end
  def teacher_followed?(topic)
    return false if topic.blank?
    if topic.respond_to?(:fid)
      self.followed_teacher_ids.include?(topic.fid)
    else
      self.followed_teacher_ids.include?(topic)
    end
  end
  def department_followed?(topic)
    return false if topic.blank?
    if topic.respond_to?(:fid)
      self.followed_department_fids.include?(topic.fid)
    else
      self.followed_department_fids.include?(topic)
    end
  end
  def topic_followed?(topic)
    return false if topic.blank?
    if topic.respond_to?(:id)
      self.followed_topic_ids.include?(topic.id)
    else
      self.followed_topic_ids.include?(topic) or self.followed_topic_ids.map{|x|x.to_s}.include?(Topic.get_id(topic))
    end
  end
  
  def mute_ask(ask_id)
    self.muted_ask_ids ||= []
    return if self.muted_ask_ids.index(ask_id)
    self.muted_ask_ids << ask_id
    self.save(:validate => false)
  end
  
  def unmute_ask(ask_id)
    self.muted_ask_ids.delete(ask_id)
    self.save(:validate => false)
  end
  def follow_ask(ask,nolog=false)
    return if self.followed_ask_ids.include? ask.id
    self.followed_ask_ids << ask.id
    self.save(:validate => false)
    ask.follower_ids << self.id
    ask.followed_count = ask.follower_ids.count
    ask.save(:validate => false)
    
    insert_follow_log("FOLLOW_ASK", ask) unless nolog
  end
  def follow_asks(asks,nolog=false)
    asks.each do |t|
      follow_ask(t,nolog)
    end
  end
  
  def unfollow_ask(ask,nolog=false)
    self.followed_ask_ids.delete(ask.id)
    self.save(:validate => false)
    
    ask.follower_ids.delete(self.id)
    ask.followed_count = ask.follower_ids.count
    ask.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_ASK", ask) unless nolog
  end
  
  
  def follow_teacher(topic,nolog=false)
    if topic.respond_to?(:id)
      topicid=topic.id
    else
      topicid=topic
    end
    return if self.followed_teacher_ids.include? topicid
    if self.is_expert
      self.tags_dpt||=[]
      self.tags_dpt << topicid unless self.tags_dpt.include?(topicid)
    end
    self.followed_teacher_ids << topicid
    self.save(:validate => false)
    topic.follower_ids << self.id
    topic.save(:validate => false)

    # 清除推荐课程
    # UserSuggestItem.delete(self.id, "Topic", topic.id)
    
    insert_follow_log("FOLLOW_TEACHER", topic) unless nolog
  end
  def follow_course(topic,nolog=false)
    if topic.respond_to?(:fid)
      topicid=topic.fid
    else
      topicid=topic
    end
    return if self.followed_course_fids.include? topicid
    if self.is_expert
      self.tags_dpt||=[]
      self.tags_dpt << topicid unless self.tags_dpt.include?(topicid)
    end
    self.followed_course_fids << topicid
    self.save(:validate => false)
    topic.follower_ids << self.id
    topic.save(:validate => false)

    # 清除推荐课程
    # UserSuggestItem.delete(self.id, "Topic", topic.id)
    
    insert_follow_log("FOLLOW_COURSE", topic) unless nolog
  end
  def follow_department(topic,nolog=false)
    if topic.respond_to?(:fid)
      topicid=topic.fid
    else
      topicid=topic
    end
    return if self.followed_department_fids.include? topicid
    if self.is_expert
      self.tags_dpt||=[]
      self.tags_dpt << topicid unless self.tags_dpt.include?(topicid)
    end
    self.followed_department_fids << topicid
    self.save(:validate => false)
    topic.follower_ids << self.id
    topic.followers_count = topic.follower_ids.count
    topic.save(:validate => false)

    # 清除推荐课程
    # UserSuggestItem.delete(self.id, "Topic", topic.id)
    
    insert_follow_log("FOLLOW_DEPARTMENT", topic) unless nolog
  end
  def follow_topic(topic,nolog=false)
    if topic.respond_to?(:id)
      topicid=topic.id
    else
      topicid=topic
    end
    return if self.followed_topic_ids.include? topicid
    if self.is_expert
      self.tags||=[]
      self.tags << topicid unless self.tags.include?(topicid)
    end
    self.followed_topic_ids << topicid
    self.save(:validate => false)
    topic.follower_ids << self.id
    topic.save(:validate => false)

    # 清除推荐课程
    # UserSuggestItem.delete(self.id, "Topic", topic.id)
    
    insert_follow_log("FOLLOW_TOPIC", topic) unless nolog
  end
  def follow_topics(topics,nolog=false)
    topics.each do |t|
      follow_topic(t,nolog)
    end
  end
  
  
  def unfollow_course(topic,withlog=true)
    self.followed_course_fids.delete(topic.id)
    self.save(:validate => false)
    
    topic.follower_ids.delete(self.id)
    topic.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_COURSE", topic) if withlog
  end
  def unfollow_teacher(topic,withlog=true)
    self.followed_teacher_ids.delete(topic.id)
    self.save(:validate => false)
    
    topic.follower_ids.delete(self.id)
    topic.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_TEACHER", topic) if withlog
  end
  def unfollow_department(topic,withlog=true)
    self.followed_department_fids.delete(topic.id)
    self.save(:validate => false)
    
    topic.follower_ids.delete(self.id)
    topic.followers_count = topic.follower_ids.count
    topic.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_DEPARTMENT", topic) if withlog
  end
  def unfollow_topic(topic,withlog=true)
    self.followed_topic_ids.delete(topic.id)
    self.save(:validate => false)
    
    topic.follower_ids.delete(self.id)
    topic.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_TOPIC", topic) if withlog
  end

  def follow(user,nolog=false)
    if user.respond_to?(:each)
      user.each do |u|
        self.follow(u,nolog)
      end
    else
      return if self.id==user.id
      return if self.following_ids.include? user.id
      self.following_ids << user.id
      self.following_count = self.following_ids.count
      self.save(:validate => false)
      user.follower_ids << self.id
      ## counter
      user.followers_count = user.follower_ids.count
      ##
      user.save(:validate => false)
      
      
      # 清除推荐课程
      # UserSuggestItem.delete(self.id, "User", user.id)

      # 发送被 Follow 的邮件
      UserMailer.deliver_delayed(UserMailer.be_followed(user.id,self.id)) unless nolog

      insert_follow_log("FOLLOW_USER", user) unless nolog
      self.redis_search_index_create
      user.redis_search_index_create
    end
    
  end
  def msg_center_action_vote(userb_id,c_id)
    usera = self
    userb = User.find(userb_id)
    ask = Ask.find(c_id)
    send_to_msg_center({
      "SourceId"=>"",
      "MsgType"=>30,
      "MsgSubType"=>3040,
      "Receiver"=>userb.zhaopin_ud,
      "Sender"=>"#{usera.name}",
      "SenderUrl"=>"http://kejian.tv/users/#{usera.slug}",
      "SendContent"=>"<P><a href=\"http://kejian.tv/users/#{usera.slug}\">#{usera.name}</a>赞同了你的解答“<a href=\"http://kejian.tv/asks/#{ask.id}\">#{ask.title}</a>”。</P>",
      "SendContentUrl"=>"",
      "OperateUrl"=>""
  	})    
  end
  
  def unfollow(user,nolog=false)
    self.following_ids.delete(user.id)
    ## counter
    self.following_count = self.following_ids.count
    ##
    self.save(:validate => false)
    
    user.follower_ids.delete(self.id)
    ## counter
    user.followers_count = user.follower_ids.count
    ##
    user.save(:validate => false)
    
    insert_follow_log("UNFOLLOW_USER", user) unless nolog

    self.redis_search_index_create
    user.redis_search_index_create
  end

  # 感谢解答
  def thank_answer(answer)
    self.thanked_answer_ids ||= []
    return true if self.thanked_answer_ids.index(answer.id)
    self.thanked_answer_ids << answer.id
    self.save(:validate => false)
    insert_follow_log("THANK_ANSWER", answer, answer.ask)
  end
  def thank_courseware(courseware)
    self.thanked_courseware_ids ||= []
    uploader = courseware.uploader.reload
    if courseware.disliked_user_ids.include?(self.id)
      ## counter
      self.disliked_coursewares_count -= 1
      uploader.dislike_coursewares_count -= 1
      courseware.disliked_count -= 1
      ##
      courseware.disliked_user_ids.delete(self.id)
    end
    if self.thanked_courseware_ids.index(courseware.id)
      self.thanked_courseware_ids.delete(courseware.id)
      courseware.thanked_user_ids.delete(self.id)
      ## counter
      self.thanked_count -= 1
      uploader.thank_count -= 1
      courseware.thanked_count -= 1
      ##
      courseware.save(:validate=>false)
      uploader.save(:validate=>false)
      self.save(:validate=>false)
      insert_follow_log("DE_THANK_COURSEWARE", courseware, courseware.topic)
      return false
    end
    self.thanked_courseware_ids << courseware.id
    courseware.thanked_user_ids << self.id
    ## counter
    self.thanked_count +=1
    uploader.thank_count += 1
    courseware.thanked_count += 1
    ##
    uploader.save(:validate=>false)
    courseware.save(:validate=>false)
    self.save(:validate => false)
    insert_follow_log("THANK_COURSEWARE", courseware, courseware.topic)
    return true
  end
  
  
  def like_playlist(playlist)
    self.thanked_play_list_ids ||= []
    if playlist.disliked_user_ids.include?(self.id)
      playlist.disliked_user_ids.delete(self.id)
      playlist.inc(:vote_down,-1)
    end
    if self.thanked_play_list_ids.index(playlist.id)
      self.thanked_play_list_ids.delete(playlist.id)
      playlist.liked_user_ids.delete(self.id)
      playlist.inc(:vote_up,-1)
      self.save(:validate =>false)
      playlist.save(:validate=>false)
      insert_follow_log("DE_LIKE_PLAYLIST", playlist)
      return false
    end
    self.thanked_play_list_ids << playlist.id
    playlist.liked_user_ids << self.id
    playlist.inc(:vote_up,1)
    playlist.save(:validate=>false)
    self.save(:validate => false)
    insert_follow_log("LIKE_PLAYLIST", playlist)
    return true
  end

  # 软删除
  # 只是把用户信息修改了
  def soft_delete(async=false)
    self.update_attribute(:name,"#{self.name.gsub('[已注销]','')}[已注销]")
    self.update_attribute(:slug,"#{self.id}")
    
    super(async)
  end
  
  #添加后台删除操作记录
  def info_delete(user_id)
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:async_info_delete,user_id)
  end
  def async_info_delete(user_id)
    self.coursewares.each do |a|
      a.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
      a.update_attribute(:deleted_at,Time.now)
      a.update_attribute(:deleted,1)
    end
    self.play_lists.each do |a|
      a.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
      a.update_attribute(:deleted_at,Time.now)
      a.update_attribute(:deleted,1)
    end
    self.comments.each do |c|
      c.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
      c.update_attribute(:deleted_at,Time.now)
      c.update_attribute(:deleted,1)
    end
  end
  #提问的疑似广告检验与处理
  def ask_advertise(ask_id)
    range=SettingItem.where(:key=>"ask_advertise_limit_time_range").first.value.to_i
    count=SettingItem.where(:key=>"ask_advertise_limit_count").first.value.to_i
    time=(a=Ask.where(:_id=>ask_id).first).blank? ? Time.now : a.created_at
    size=Ask.where(:user_id=>self.id,:created_at.gt=>time-range.minute,:created_at.lte=>time).count
    if size>count
      deal_range=SettingItem.where(:key=>"ask_advertise_limit_deal_range").first.value.to_i
      self.update_attribute(:user_type,User::FROZEN_USER)
      Ask.where(:user_id=>self.id,:created_at.gt=>time-deal_range.hour).each do |a|
        a.update_attribute(:deleted,3)
        a.redis_search_index_destroy
      end
    end
  end
  #解答的疑似广告检验与处理
  def answer_advertise(answer_id)
    range=SettingItem.where(:key=>"answer_advertise_limit_time_range").first.value.to_i
    count=SettingItem.where(:key=>"answer_advertise_limit_count").first.value.to_i
    time=(a=Answer.where(:_id=>answer_id).first).blank? ? Time.now : a.created_at
    size=Answer.where(:user_id=>self.id,:created_at.gt=>time-range.minute,:created_at.lte=>time).count
    if size>count
      deal_range=SettingItem.where(:key=>"answer_advertise_limit_deal_range").first.value.to_i
      self.update_attribute(:user_type,User::FROZEN_USER)
      Answer.where(:user_id=>self.id,:created_at.gt=>time-deal_range.hour).each do |a|
        a.update_attribute(:deleted,3)
      end
    end
  end
  #评论的疑似广告检验与处理
  def comment_advertise(comment_id)
    range=SettingItem.where(:key=>"answer_advertise_limit_time_range").first.value.to_i
    count=SettingItem.where(:key=>"answer_advertise_limit_count").first.value.to_i
    time=(c=Comment.where(:_id=>comment_id).first).blank? ? Time.now : c.created_at
    size=Comment.where(:user_id=>self.id,:created_at.gt=>time-range.minute,:created_at.lte=>time).count
    if size>count
      deal_range=SettingItem.where(:key=>"answer_advertise_limit_deal_range").first.value.to_i
      self.update_attribute(:user_type,User::FROZEN_USER)
      Comment.where(:user_id=>self.id,:created_at.gt=>time-deal_range.hour).each do |c|
        c.update_attribute(:deleted,3)
      end
    end
  end
  # 我的通知
  def unread_notifies
    notifies = {}
    notifications = self.notifications.nondeleted.unread.desc('created_at') #.includes(:log)
    notifications.each do |notify|
      notifies[notify.target_id] ||= {}
      notifies[notify.target_id][:items] ||= []
      
      case notify.action
      when "FOLLOW" then notifies[notify.target_id][:type] = "USER"
      when "THANK_ANSWER" then
        notifies[notify.target_id][:type] = "THANK_ANSWER"
      when "INVITE_TO_ANSWER" then notifies[notify.target_id][:type] = "INVITE_TO_ANSWER"
      when "NEW_TO_USER" then notifies[notify.target_id][:type] = "ASK_USER"
      else  
        notifies[notify.target_id][:type] = "ASK"
      end
      if "THANK_ANSWER"==notify.action
        if answer = Answer.find(notify.target_id)
          if ask=answer.ask
            notifies[ask.id]||={}
            notifies[ask.id][:items]||=[]
            notifies[ask.id][:items]<<notify
          end
        end
      else
        notifies[notify.target_id][:items] << notify
      end
    end
    
    [notifies, notifications]
  end

  # 推荐给我的人或者课程
  def suggest_items
    # return UserSuggestItem.gets(self.id, :limit => 6)
    topics = Topic.desc('hot_rank').collect{|x| [x.name,x.followers_count]}
    
    already = self.followed_topic_ids
    already ||= []
    already_names = already.collect{|id| if topic=Topic.where(_id:id).first;topic.name;else;nil;end}.compact
    topics = topics.delete_if{ |x| already_names.include?(x[0]) }
    topics = topics[0..2] if topics.size>3
    ret = []
    ret += topics.collect{|n|Topic.where(name:n[0]).first}
    ret += self.following.limit(2).to_a
    return ret
  end
  
  # 刷新推荐的人
  # def refresh_suggest_items
  #   related_people = self.followed_topics.inject([]) do |memo, topic|
  #     memo += topic.followers
  #   end.uniq
  #   related_people = related_people - self.following - [self] if related_people
  #   
  #   related_topics = self.following.inject([]) do |memo, person|
  #     memo += person.followed_topics
  #   end.uniq
  #   related_topics -= self.followed_topics if related_topics
  #   
  #   items = related_people + related_topics
  #   # 存入 Redis
  #   saved_count = 0
  #   # 先删除就的缓存
  #   UserSuggestItem.delete_all(self.id)
  #   mutes = UserSuggestItem.get_mutes(self.id)
  #   items.shuffle.each do |item|
  #     klass = item.class.to_s
  #     # 跳过 mute 的信息
  #     next if mutes.include?({"type" => klass, "id" => item.id.to_s})
  #     # 跳过删除的用户
  #     next if klass == "User" and item.deleted == 1
  #     usi = UserSuggestItem.new(:user_id => self.id, 
  #                               :type => klass,
  #                               :id => item.id)
  #     if usi.save
  #       saved_count += 1
  #     end
  #   end
  #   saved_count
  # end
  cache_consultant :id,:from_what => :uid,:no_callbacks=>true
  cache_consultant :name,:no_callbacks=>true
  cache_consultant :uid,:no_callbacks=>true
  cache_consultant :email,:no_callbacks=>true
  cache_consultant :slug,:no_callbacks=>true
  def self.get_avatar_changed_at(uid)
    $redis_users.hget(uid,:avatar_changed_at)    
  end
  cache_consultant :avatar_filename,:no_callbacks=>true
  cache_consultant :is_expert_why,:redis_varname=>'$redis_experts',:no_callbacks=>true
  cache_consultant :reputation,:no_callbacks=>true
  before_create :check_slug_presence
  def check_slug_presence
    self.slug = self.id.to_s unless self.slug.present?
    return true
  end
  after_create :update_consultant!
  def update_consultant!
    $redis_users.hset(self.uid,:id,self.id.to_s)
    $redis_users.hset(self.id,:name,self.name)
    $redis_users.hset(self.id,:uid,self.uid)
    $redis_users.hset(self.id,:email,self.email)
    $redis_users.hset(self.id,:slug,self.slug)
    # $redis_users.hset(self.id,:fangwendizhi,self.fangwendizhi)
    $redis_users.hset(self.id,:avatar_filename,self.avatar_filename)
    $redis_users.hset(self.uid,:avatar_changed_at,self.avatar_changed_at.to_i)
  end
  def play_lists
    PlayList.undestroyable.nondeleted.where(:user_id=>self.id)
  end
  def all_play_lists
    PlayList.nondeleted.where(:user_id=>self.id)
  end
  def play_lists_ugc
    PlayList.nondeleted.where(:user_id=>self.id,:undestroyable.ne => true)
  end
  def already_jubao(url)
    name = self.name
    ReportSpam.where(:url => url).each do |item|
      item.descriptions.each do |desc|
        if desc.starts_with?(name)
          return true
        end
      end
    end
    return false
  end
  def activationauth(formhash)
    UCenter::Php.authcode("#{self.slug}\t#{formhash}", 'ENCODE', UCenter.getdef('UC_KEY'))
  end
  def self.import_from_dz!(info0)
    return nil if '0'==info0
    info = info0['root']['item']
    incoming_opts = {'email' => info[2], 'username' => info[1], 'uid' => info[0]}
    u = nil
    u||= User.where(:email=>incoming_opts['email']).first
    u||= User.where(:slug=>incoming_opts['username']).first
    u||= User.new
    if u.name.blank?
      u.name = incoming_opts['username']
      if !u.valid?
        if u.errors[:name].present?
          u.name = '_'+u.name
        end
      end
    end
    u.uid = incoming_opts['uid'].to_i
    u.email = incoming_opts['email']
    u.slug = incoming_opts['username']
    u.save(:validate=>false)
    u.update_consultant! unless u.new_record?
    return u
  end
  def self.import_from_ibeike!(info0)
    return nil if '0'==info0
    info = info0['root']['item']
    incoming_opts = {'email' => info[2], 'username' => info[1], 'uid' => info[0]}
    u = nil
    u||= User.where(:email=>incoming_opts['email']).first
    u||= User.where(:ibeike_slug=>incoming_opts['username']).first
    u||= User.new
    u.name = "_#{incoming_opts['username']}"
    u.ibeike_uid = incoming_opts['uid'].to_i
    u.email = incoming_opts['email']
    u.ibeike_slug = incoming_opts['username']
    u.save(:validate=>false)
    u.update_consultant! unless u.new_record?
    if u.uid.blank?
      ret = UCenter::User.get_user(nil,{username:u.email,isemail:1})
      if '0'!=ret
        u.update_attribute(:uid,ret['root']['item'][0].xi.to_i)
      else
        ret = UCenter::User.register(nil,{
          username:u.slug,
          password:rand.to_s,
          email:u.email,
          regip:'0.0.0.0',
          psvr_force:'1'
        })
        if ret.xi.to_i>0
          u.update_attribute(:uid,ret.xi.to_i)
        else
          raise 'iBeiKe注册UC同步注册错误！！！猿快来看一下！'
        end
      end
    end
    return u
  end
  def self.authenticate_through_dz_auth!(request,discuz_uid)
    u = User.where(:uid=>discuz_uid).first
    return u if u.present? and u.email.present? and u.slug.present?
    info0 = UCenter::User.get_user(request,{username:discuz_uid,isuid:1})
    u = import_from_dz!(info0)
    return u
  end
  def sync_to_uc!
    info0 = UCenter::User.get_user(nil,{username:self.email,isemail:1})
    if '0'==info0
      ret = UCenter::User.register(nil,{psvr_force:1,username:self.slug,password:self.encrypted_password,email:self.email,regip:self.regip})
      binding.pry unless Integer(ret) > 0
    else
      ret = UCenter::User.update(nil,{ignoreoldpw:1,username:self.slug,newpw:self.encrypted_password,email:self.email})
      return 'protected users, okay to ignore' if '-8'==ret
      binding.pry unless Integer(ret) >= 0
    end
    d = Ktv::Discuz.new
    d.login!(self.slug,self.encrypted_password)
    d.activate_user!
    return nil
  end
  protected
  
  def insert_follow_log(action, item, parent_item = nil)
    begin

      if ["FOLLOW_TOPIC", "UNFOLLOW_TOPIC"].include?(action) and log = UserLog.where(:user_id=>self.id,:action=>action,:created_at.gt=>1.hours.ago).first          
        log.target_ids ||= []
        log.target_ids.delete(item.id)
        log.target_ids << item.id
        log.save(:validate => false)
        return
      end

      log = UserLog.new
      log.user_id = self.id
      log.title = self.name
      log.target_id = item.id
      log.target_ids = [item.id]
      log.action = action
      if parent_item.blank?
        log.target_parent_id = item.id
        log.target_parent_title = item.is_a?(Ask) ? item.title : item.name
      else
        log.target_parent_id = parent_item.id
        log.target_parent_title = parent_item.title
      end
      log.diff = ""
      log.save(:validate => false)

    rescue Exception => e
        
    end
  end
end

