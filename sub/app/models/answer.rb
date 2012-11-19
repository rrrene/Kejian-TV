# -*- encoding : utf-8 -*-
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel  
  # index :created_at
  def self.real_create(params,current_user)
    if params[:did_editor_content_formatted] == "no"
      body = simple_format(params[:answer][:body].strip) 
    else
      body = params[:answer][:body]
    end
    ask = Ask.where(_id:Moped::BSON::ObjectId(params[:id])).first
    success,answer = ask.answer(body,current_user)
    return [ask,success,answer]
  end
  def asynchronously_clean_me
    bad_ids = [self.id]
    Util.bad_id_out_of!(User,:thanked_answer_ids,bad_ids)
    Util.del_propogate_to(Comment,:_id,self.comments.collect(&:id))
    self.logs.each do |c|
      Notification.where(:log_id=>c._id).each do |n|
        n.update_attribute(:deleted,1)
      end
      c.delete
    end
    # ------------------------------
    ask = self.ask
    if ask
      ask.inc(:answers_count,-1)
      ask.set_first_answer
      ask.save
    end
    self.user.inc(:answers_count,-1)
    self.up_voters(User).each do |u|
      u.inc(:vote_up_count,-1)
    end
    self.down_voters(User).each do |u|
      u.inc(:vote_down_count,-1)
    end
    thanked = false
    User.where(:thanked_answer_ids=>self.id).each do |u|
      u.inc(:thank_count,-1)
      thanked = true
    end
    self.user.inc(:thanked_count,-1) if thanked
    self.ask.redis_search_index_create
    self.user.redis_search_index_create
  end
  field :body

  field :comments_count, :type => Integer, :default => 0
  field :vote_up_count, :type => Integer, :default => 0
  field :vote_down_count, :type => Integer, :default => 0
  field :thanked_count, :type => Integer, :default => 0
  field :spams_count, :type => Integer, :default => 0
  #后台删除操作记录
  field :deletor_id

  #添加后台删除操作记录
  def info_delete(user_id)
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:async_info_delete,user_id)
  end
  def async_info_delete(user_id)
    self.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
    self.comments.each do |c|
      c.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
    end
  end
  before_save :counter_work
  def counter_work
    if new_record?
      self.user.inc(:answers_count,1)
      self.ask.inc(:answers_count,1)
    end
  end  
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :body
      '内容'
    else
      attr.to_s
    end
  end

  def body_plain
    Nokogiri.HTML(self.body).text()
  end
  belongs_to :ask, :inverse_of => :answers
  
  after_create proc{
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:msg_center_action)
  }
  def msg_center_action
    send_to_msg_center({
      "SourceId"=>"",
      "MsgType"=>30,
      "MsgSubType"=>3010,
      "Receiver"=>self.ask.user.zhaopin_ud,
      "Sender"=>"#{self.user.name}",
      "SenderUrl"=>"http://kejian.tv/users/#{self.user.slug}",
      "SendContent"=>"<P><a href=\"http://kejian.tv/users/#{self.user.slug}\">#{self.user.name}</a>解答了你的题“<a href=\"http://kejian.tv/asks/#{self.ask.id}\">#{self.ask.title}</a>”。</P>",
      "SendContentUrl"=>"",
      "OperateUrl"=>""
  	})
  	self.ask.followers.each do |item|
  	  send_to_msg_center({
        "SourceId"=>"",
        "MsgType"=>30,
        "MsgSubType"=>3020,
        "Receiver"=>item.zhaopin_ud,
        "Sender"=>"#{self.user.name}",
        "SenderUrl"=>"http://kejian.tv/users/#{self.user.slug}",
        "SendContent"=>"<P><a href=\"http://kejian.tv/users/#{self.user.slug}\">#{self.user.name}</a>解答了你关注的题“<a href=\"http://kejian.tv/asks/#{self.ask.id}\">#{self.ask.title}</a>”。</P>",
        "SendContentUrl"=>"",
        "OperateUrl"=>""
    	})
    end
  end

  belongs_to :user, :inverse_of => :answers#, :counter_cache => true [todo]
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"

  # index :ask_id
  # index :user_id
  
  field :spam_voter_ids, :type => Array, :default => []
  
  has_many :comments, as: :commentable
  
  validates_presence_of :user_id, :body
  validate :unique_user_id
  def unique_user_id
    if self.ask.answers.nondeleted.where(user_id:self.user_id,:_id.ne=>self.id).first
      errors.add(:base, '您已经解答过了')
    end
  end
  validate :text_length
  def text_length
    body = Nokogiri.HTML(self.body).text()
    if body.length>10000
      errors.add(:base, '内容太长了！')
    end
  end
  validate :check_to_user
  def check_to_user
    ask = self.ask
    if !ask.to_user.blank? and self.user_id != ask.to_user_id
      errors.add(:base, '这个题是定向提问，您不是提问对象故不能解答')
    end
  end
  # 支持者
  # def up_voters
  #   # TODO: 这里需要加上缓存
  #   ids = self.up_voter_ids[0,(self.up_voter_ids.count > 30 ? 30 : self.up_voter_ids.count)]
  #   items = User.find(ids)
  #   items.sort { |y,x| x.score <=> y.score }
  # end

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("body")
      return false
    end
  end

  after_create :mail_deliver_new_answer
  def mail_deliver_new_answer
    UserMailer.new_answer_to_followers(self.id)
  end
  
  def chomp_body()
    chomped = self.body
    while chomped =~ /<div><br><\/div>$/i
      chomped = chomped.gsub(/<div><br><\/div>$/i, "")
    end
    return chomped
  end

  # 没有帮助
  def spam(voter_id,size = 1)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.inc(:spams_count,size)
    self.spam_voter_ids << voter_id
    self.save()
    return self.spams_count
  end

  after_create :save_to_ask_and_update_answered_at
  before_update :log_update
  
  def log_update
    insert_action_log("EDIT") if self.body_changed?
  end
  
  def save_to_ask_and_update_answered_at
    self.ask.set_first_answer
    self.ask.save
    self.user.save
    # 解答默认关注题
    self.user.follow_ask(self.ask) if !self.user.ask_followed?(self.ask)
    
    # 保存用户解答过的题列表
    if !self.user.answered_ask_ids.index(self.ask_id)
      self.user.answered_ask_ids << self.ask_id
      self.user.save
    end
    
    self.user.redis_search_index_create
    self.ask.redis_search_index_create

    insert_action_log("NEW")
  end
  


  protected
  
  def insert_action_log(action)
    begin
      log = AnswerLog.new
      log.user_id = self.user_id
      log.title = self.body
      log.answer = self
      log.target_id = self.id
      log.target_attr = self.body_changed? ? "BODY" : "" if action == "EDIT"
      log.action = action
      log.target_parent_id = self.ask_id
      log.target_parent_title = self.ask.title
      log.diff = ""
      log.save
    rescue Exception => e
        
    end
      
  end
  
end
