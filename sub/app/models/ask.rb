# -*- encoding : utf-8 -*-
class Ask
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  @before_soft_delete = proc{
    redis_search_index_destroy
  }
  @after_soft_delete = proc{
    $redis_asks.hdel self.id,:title
  }
  attr_accessible :title,:body
  def self.real_create(params,current_user)
    invite=nil
    ask = Ask.where(:title=>params[:ask][:title]).nondeleted.last
    params_ask_to_user_id = nil#params[:ask][:to_user_id]
    if(!params[:onlyhim])
      # PSVR>
      # in which circumstances
      # it should be made like create and invite
      params_ask_to_user_id = params[:ask][:to_user_id]
      params[:ask][:to_user_id] = nil
    end
    if ask and (!(params[:ask][:to_user_id]||ask.to_user_id) || ask.to_user_id==params[:ask][:to_user_id])
      return [1,ask,invite]
    end
    ask = Ask.new(params[:ask])
    ask.user_id = current_user.id
    ask.follower_ids << current_user.id
    ask.current_user_id = current_user.id
    if ask.save
      if(params_ask_to_user_id)
        invite = AskInvite.invite(ask.id, params_ask_to_user_id, current_user.id)
      end
      AskSuggestTopic.find_by_ask(ask).each do |name|
        ask.update_topics(name,"1",current_user.id)
      end
      ask.update_topics(params[:topics],"1",current_user.id) unless params[:topics].blank?
      return [2,ask,invite]
    else
      return [3,ask,invite]
    end
  end

  def as_json(opts={})
    if opts[:wendao_show]
      super(opts)
    else
      {id:self.id,title:title,user:[User.get_slug(self.user_id),User.get_name(self.user_id)],answers_count:self.answers_count}
    end
  end

  def asynchronously_clean_me
    bad_ids = [self.id]
    Util.bad_id_out_of!(User,:followed_ask_ids,bad_ids)
    Util.bad_id_out_of!(User,:muted_ask_ids,bad_ids)
    Util.bad_id_out_of!(User,:answered_ask_ids,bad_ids)
    Util.del_propogate_to(Answer,:ask_id,bad_ids)
    Util.del_propogate_to(AskInvite,:ask_id,bad_ids)
    Util.del_propogate_to(AskSuggestTopic,:ask_id,bad_ids)
    Util.del_propogate_to(Comment,:_id,self.comments.collect(&:id))
    self.logs.each do |c|
      Notification.where(:log_id=>c._id).each do |n|
        n.update_attribute(:deleted,1)
      end
      c.delete
    end
    AskCache.where(:ask_id=>self.id).delete_all
    # ------------------


    self.user.inc(:asks_count,-1)
    self.topics.each do |t|
      topic=Topic.find_by_name(t)
      if !topic.blank?
        topic.inc(:asks_count,-1)
      end
    end
  end

  cache_consultant :title
  field :no_display_at_index,:type=>Boolean,:default=>false
  field :will_autofollow,:type=>Boolean,:default=>false
  field :title
  field :body
  field :body2
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :body
      '内容'
    else
      attr.to_s
    end
  end

  # after create,
  # asynchronously generate its body content for cache use
  # after_save proc{
  #   Sidekiq::Client.enqueue(Askbody2Job,ask_id:self.id)
  # }
  def body_plain
    Nokogiri.HTML(self.body).text()
  end
  # 最后解答时间
  # field :answer_up_count, :type => Integer, :default => 0 # 首答案赞成票数
  field :answers_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :followed_count, :type => Integer, :default => 0
  field :topic_count, :type => Integer, :default => 0
  field :shared_count, :type => Integer, :default => 0
  field :spams_count, :type => Integer, :default => 0
  field :views_count, :type => Integer, :default => 0  
  before_save :counter_work
  def counter_work
    self.topic_count = self.topics.count
    if new_record?
      self.user.inc(:asks_count,1)
    end
  end
  # index :spams_count
    
  field :answered_at, :type => Time
  field :topics, :type => Array, :default => []
  field :spam_voter_ids, :type => Array, :default => []
  # 最后活动时间，这个时间应该设置为该题下辖最后一条log的发生时间
  field :last_updated_at, :type => Time
  # 重定向题编号
  field :redirect_ask_id
  #后台删除操作记录
  field :deletor_id
  #添加后台删除操作记录
  def info_delete(user_id)
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:async_info_delete,user_id)
  end
  def async_info_delete(user_id)
    self.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
    self.answers.each do |a|
      a.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
    end
    self.comments.each do |c|
      c.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
    end
  end
  #更新首页热门题
  def refresh_hot_asks
    $asks = Ask.normal.nondeleted.where(:created_at.gt=>SettingItem.find_or_create_by(:key=>"hot_asks_created_at").value.to_i.days.ago,:answers_count.gte=>SettingItem.find_or_create_by(:key=>"hot_asks_answers_count").value.to_i).to_a.collect{|x| [x,x.last_answer.blank? ? 0 : x.last_answer.created_at]}
    if SettingItem.find_or_create_by(:key=>"hot_asks_sort_by").value.to_s=="answers_count"
      $asks =$asks.sort{|x,y|y[0].answers_count.to_i<=>x[0].answers_count.to_i}
    else
      $asks =$asks.sort{|x,y|y[1].to_i<=>x[1].to_i}
    end
  
    # AskCache.delete_all
    Mongoid.database.collection('ask_caches').drop
    $asks.each_with_index do |a,i|
      ask=a[0]
      AskCache.create!(ask_id:ask.id,hot_rank:i)
    end
  end
  # index :created_at
  # index :topics
  # index :user_id

  field :hot_rank,:type=>Integer,:default=>0
  # 提问人
  belongs_to :user, :inverse_of => :asks
  # 对指定人的提问
  belongs_to :to_user, :class_name => "User"

  # 解答
  has_many :answers
  # Log
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  # 最后个解答
  belongs_to :last_answer, :class_name => 'Answer'
  # 最后解答者
  belongs_to :last_answer_user, :class_name => 'User'
  # Followers
  has_and_belongs_to_many :followers, :inverse_of => :followed_asks, :class_name => "User"
  # field :follower_ids, :type => Array, :default => []
  # Comments
  has_many :comments, as: :commentable

  has_many :ask_invites

  attr_protected :user_id
  attr_accessor :current_user_id
  validates_presence_of :user_id, :title
  validates_presence_of :current_user_id, :if => proc { |obj| obj.title_changed? or obj.body_changed? }
  validates_length_of :title,:maximum=>100

  # 正常可显示的题, 前台调用都带上这个过滤
  scope :normal, where(:spams_count.lt => Setting.ask_spam_max)
  scope :unanswered, where(:answers_count => 0)
  def is_normal?
    spams_count < Setting.ask_spam_max
  end
  scope :last_actived, desc(:answered_at)
  # 除开一些 id，如用到 mute 的题，传入用户的 muted_ask_ids
  scope :exclude_ids, lambda { |id_array| not_in("_id" => (id_array ||= [])) } 
  scope :only_ids, lambda { |id_array| any_in("_id" => (id_array ||= [])) } 
  # 问我的题
  field :to_user_ids
  scope :asked_to, lambda { |to_user_id| any_of({:to_user_id => to_user_id},{:to_user_ids=>to_user_id}) }

  redis_search_index(:title_field => :title,:ext_fields => [:topics,:answers_count,:created_at], :score_field => :views_count)

  validates_length_of :body,:maximum=>6000

  before_save :fill_default_values
  after_create :create_log, :send_mails
  after_destroy :dec_counter_cache
  before_update :update_log

  def view!
    self.inc(:views_count, 1)
  end

  def send_mails
    # 向某人提问
    if !self.to_user.blank?
      if self.to_user.mail_ask_me
        UserMailer.deliver_delayed(UserMailer.ask_user(self.id))
      end
    end
  end


  def update_log
    return if self.current_user_id.blank?
    user = User.where(_id:current_user_id).first
    unless user and user.admin?
      insert_action_log("EDIT") if self.title_changed? or self.body_changed?
    end
  end
  
  def create_log
    insert_action_log("NEW")
    if self.to_user_id
      arr=Ask.normal.recent.limit(6).collect(&:to_user_id)
      arr.delete(self.to_user_id)
      if(arr.empty?)
        self.no_display_at_index = true
        self.save!
      end
      ask_id = self.id
      user_id = self.to_user_id
      invitor_id = self.user_id
      # AskInvite.insert_log(ask_id, user_id, invitor_id)
    end
  end
  
  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("title")
      return false
    end

    if self.spam?("body")
      return false
    end

    if self.spam?("topics")
      return false
    end
  end

  def chomp_body
    if self.body == "<br>"
      return ""
    else
      chomped = self.body
      while chomped =~ /<div><br><\/div>$/i
        chomped = chomped.gsub(/<div><br><\/div>$/i, "")
      end
      return chomped
    end
  end
  
  def fill_default_values
    # 默认回复时间为当前时间，已便于排序
    if self.answered_at.blank?
      self.answered_at = Time.now
    end
  end

  # 更新课程
  # 参数 topics 可以是数组或者字符串
  # 参数 add  true 增加, false 去掉
  def update_topics(topics, add = true, current_user_id = nil)
    self.topics = [] if self.topics.blank?
    # 分割逗号
    topics = topics.split(/，|,/) if topics.class != [].class
    # 去两边空格
    topics = topics.collect { |t| t.strip if !t.blank? }.compact
    action = nil

    if add
      # 保存为独立的课程
      new_topics = Topic.save_topics(topics, current_user_id)
      self.topics += new_topics
      action = "ADD_TOPIC"
    else
      self.topics -= topics
      action = "DEL_TOPIC"
    end
    
    self.current_user_id = current_user_id
    self.topics = self.topics.uniq { |s| s.downcase }
    self.update(:topics => self.topics)
    Topic.where(:name.in=>topics).each do |topic|
      topic.update_attribute(:asks_count,topic.asks.nondeleted.count)
      topic.redis_search_index_create
    end
    insert_topic_action_log(action, topics, current_user_id)
  end

  # 提交题为 spam
  def spam(voter_id,size = 1)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.inc(:spams_count,size)
    self.spam_voter_ids << voter_id
    self.current_user_id = "NULL"
    self.save
    return self.spams_count
  end

  def self.search_title(text,options = {})
    limit = options[:limit] || 10
    Ask.search(text,:limit => limit)
  end

  def self.find_by_title(title)
    first(:conditions => {:title => title})
  end
  
  # 重定向题
  def redirect_to_ask(to_id)
    # 不能重定向自己
    return -2 if to_id.to_s == self.id.to_s
    @to_ask = Ask.find(to_id)
    # 如果重定向目标的是重定向目前这个题的，就跳过，防止无限重定向
    return -1 if @to_ask.redirect_ask_id.to_s == self.id.to_s
    self.redirect_ask_id = to_id
    self.save
    1
  end

  # 取消重定向
  def redirect_cancel
    self.redirect_ask_id = nil
    self.save
  end
  
  def set_first_answer
    ans = self.answers.nondeleted.desc('created_at').first
    if ans
      self.answered_at = ans.created_at
      self.last_answer_id = ans.id
      self.last_answer_user_id = ans.user_id
      self.current_user_id = ans.user_id
    else
      self.answered_at = self.last_answer_id = self.last_answer_user_id = self.current_user_id = nil
    end
  end

  # answer a specific ask, returns true or false for success or failure
  # params: body of the answer
  def answer(ans_body,by_who)
    @answer = Answer.new
    @answer.ask_id = self.id
    @answer.user_id = by_who.id
    @answer.body = ans_body
    [@answer.save,@answer]
  end
  

  protected
  
  def insert_topic_action_log(action, topics, current_user_id)
    begin
      log = AskLog.new
      log.user_id = current_user_id
      log.title = topics.join(',')
      log.ask = self
      log.target_id = self.id
      log.action = action
      log.target_parent_id = self.id
      log.target_parent_title = self.title
      log.diff = ""
      log.save
    rescue Exception => e
        
    end
  end
  
  def insert_action_log(action)
    begin
      log = AskLog.new
      log.user_id = self.current_user_id
      log.title = self.title
      log.ask = self
      log.target_id = self.id
      log.target_attr = (self.title_changed? ? "TITLE" : (self.body_changed? ? "BODY" : "")) if action == "EDIT"
      if(action == "NEW" and !self.to_user_id.blank?)
        action = "NEW_TO_USER"
        log.target_parent_id = self.to_user_id
      end
      log.action = action
      log.diff = ""
      log.save
    rescue Exception => e
        
    end
  end

end
