# -*- encoding : utf-8 -*-
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include BaseModel
  def self.real_create(params,current_user)
# params is like
# {"utf8"=>"✓",
#  "authenticity_token"=>"/cc04uIQtllZhTCOXvDS/qT5cZRph+sUTN2/lQBkRRM=",
#  "comment"=>
#   {"commentable_type"=>"Courseware",
#    "commentable_id"=>"50a116a6e138239259000007",
#    "body"=>"fadsdfsa"},
#  "action"=>"create",
#  "controller"=>"comments"}
    comment = Comment.new
    comment.body = params[:comment]['body']
    comment.commentable_id = params[:comment]['commentable_id']
    comment.commentable_type = params[:comment]['commentable_type'].titleize
    if !params[:comment]['replied_to_comment_id'].nil?
        comment.replied_to_comment_id = params[:comment]['replied_to_comment_id']
    end
    comment.user_id = current_user.id
    return [comment.save,comment]
  end
  def asynchronously_clean_me
    # --------------
    self.user.inc(:comments_count,-1)
    self.commentable.inc(:comments_count,-1)
    self.logs.each do |c|
      Notification.where(:log_id=>c._id).each do |n|
        n.update_attribute(:deleted,1)
      end
      c.delete
    end
  end
  field :body
  field :voteup,:type => Integer, :default => 0
  field :votedown,:type => Integer, :default => 0
  field :voteup_user_ids,:type=>Array,:default => []
  field :votedown_user_ids,:type=>Array,:default => []
  field :replied_to_comment_id

  #后台删除操作记录
  field :deletor_id
  #添加后台删除操作记录
  def info_delete(user_id)
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:async_info_delete,user_id)
  end
  def async_info_delete(user_id)
    self.update_attribute(:deletor_id,Moped::BSON::ObjectId(user_id))
  end
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :ask, :foreign_key => "commentable_id"
  belongs_to :answer, :foreign_key => "commentable_id"
  belongs_to :courseware, :foreign_key => "commentable_id"
  
  belongs_to :user
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  
  # index :user_id
  # index :commentable_type
  # index :commentable_id
  # index :created_at

  validates_presence_of :body
  validates_length_of :body,:maximum=>500,:minimum=>10

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("body")
      return false
    end
  end

  before_create :fix_commentable_id
  def fix_commentable_id
    if self.commentable_id.class == "".class
      self.commentable_id = Moped::BSON::ObjectId(self.commentable_id)
    end
  end
  before_save :counter_work
  def counter_work
    if new_record?
      self.commentable.inc(:comments_count,1)
      self.user.inc(:comments_count,1)
    end
  end
  # after_create :create_log
  def disliked_by_user(user)
    #todo
  end
  def create_log
    log = CommentLog.new
    log.user_id = self.user_id
    log.comment = self
    log.target_id = self.id
    log.action = "NEW_#{self.commentable_type.upcase}_COMMENT"
    if self.commentable_type == "Answer"
      log.target_parent_id = (self.answer and self.answer.ask) ? self.answer.ask.id : ""
      log.target_parent_title = (self.answer and self.answer.ask) ? self.answer.ask.title : ""
      log.title = self.commentable_id
    elsif self.commentable_type == "Ask"
      log.target_parent_title = self.ask ? self.ask.title : ""
      log.target_parent_id = self.commentable_id
      log.title = log.target_parent_title
    elsif self.commentable_type == "Courseware"
      log.target_parent_title = self.courseware ? self.courseware.title : ""
      log.target_parent_id = self.commentable_id
      log.title = log.target_parent_title
    end
    log.diff = ""
    log.save
  end


  # 
  # after_destroy :dec_counter_cache
  # def dec_counter_cache
  #   self.commentable.comments_count = self.commentable.comments.count
  #   self.commentable.save
  # end
end
