# -*- encoding : utf-8 -*-
class Log
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title
  field :target_attr
  field :action
=begin
  all possible 16 actions:
  => ["NEW",
   "ADD_TOPIC",
   "FOLLOW_TOPIC",
   "FOLLOW_ASK",
   "UNFOLLOW_ASK",
   "EDIT",
   "AGREE",
   "THANK_ANSWER",
   "NEW_TO_USER",
   "DEL_TOPIC",
   "NEW_ANSWER_COMMENT",
   "FOLLOW_USER",
   "INVITE_TO_ANSWER",
   "NEW_ASK_COMMENT",
   "UNFOLLOW_USER",
   "UNFOLLOW_TOPIC"]
=end
  field :diff
  field :target_id
  field :target_ids
  field :target_parent_id
  field :target_parent_title
  field :body # so this is the field that contains its rendered raw HTML...
  field :from_mobile, :type => Integer, :default=>0
  
  # index :target_attr
  # index :action
  # index :target_id
  # index :_type
  # index :user_id
  def as_json(opts={})
    {action:self.action,id:self.id,title:self.title,user_id:self.user_id,target_id:self.target_id}
  end
  
  belongs_to :user, :inverse_of => :logs
  
  attr_protected :user_id
  # after create,
  # asynchronously generate its body content for cache use
  after_create proc{
    Sidekiq::Client.enqueue(LogbodyJob,log_id:self.id)
  }
end

class AskLog < Log
  belongs_to :ask, :inverse_of => :logs, :foreign_key => :target_id

  # after_create :send_notification
  after_create proc{
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:send_notification)
  }
  
  def send_notification
    case self.action
    when "INVITE_TO_ANSWER"
      Notification.create!(user_id: self.target_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: "INVITE_TO_ANSWER")
    when "NEW_TO_USER"
      Notification.create!(user_id: self.target_parent_id, 
                          log_id: self.id, 
                          target_id: self.target_id, 
                          action: "ASK_USER")
    end
  end
end

class TopicLog < Log
  belongs_to :topic, :inverse_of => :logs, :foreign_key => :target_id
end

class UserLog < Log
  # belongs_to :user, :inverse_of => :logs, :foreign_key => :target_id
  
  validates_uniqueness_of :target_id, 
                          :scope => [:user_id, :target_id, :target_parent_id], 
                          :if => proc { |obj| obj.action == "AGREE" }

  # after_create :send_notification
  after_create proc{
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:send_notification)
  }
  
  def send_notification
    case self.action
    when "FOLLOW_USER"
      Notification.create(user_id: self.target_id, 
                          log_id: self.id, 
                          target_id: self.target_id, 
                          action: "FOLLOW")
    when "AGREE"
      answer = Answer.find(self.target_id)
      Notification.create(user_id: answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: "AGREE_ANSWER") if answer
    when "THANK_ANSWER"
      answer = Answer.find(self.target_id)
      Notification.create(user_id: answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_id,
                          action: self.action)
    end
  end
end

class AnswerLog < Log
  belongs_to :answer, :inverse_of => :logs, :foreign_key => :target_id
  
  # after_create :send_notification
  after_create proc{
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:send_notification)
    }
  
  def send_notification
    case self.action
    when "NEW"
      self.answer.ask.follower_ids.each do |follower_id|
        if follower=User.where(_id:follower_id).first
          Notification.create(user_id: follower.id,
                              log_id: self.id, 
                              target_id: self.target_parent_id, 
                              action: "NEW_ANSWER") unless follower.id==self.user_id
        end
      end
    end
  end
end

class CommentLog < Log
  belongs_to :comment, :inverse_of => :logs, :foreign_key => :target_id
  
  # after_create :send_notification
  after_create proc{
    Sidekiq::Client.enqueue(HookerJob,self.class.to_s,self.id,:send_notification)
    }
  
  def send_notification
    case self.action
    when "NEW_ASK_COMMENT"
      Notification.create(user_id: self.comment.ask.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: self.action) if self.comment and self.comment.ask and self.comment.ask.user_id != self.comment.user_id
    when "NEW_ANSWER_COMMENT"
      Notification.create(user_id: self.comment.answer.user_id, 
                          log_id: self.id, 
                          target_id: self.target_parent_id, 
                          action: self.action) if self.comment and self.comment.answer and self.comment.answer.ask and self.comment.answer.user_id != self.comment.user_id
    end
  end
end
