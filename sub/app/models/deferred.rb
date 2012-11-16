# -*- encoding : utf-8 -*-
class Deferred
  include Mongoid::Document
  include Mongoid::Timestamps
  
  include BaseModel
  
  field :body
  field :controller
  field :user_id
  field :content
  
  belongs_to :user
  
  scope :asks,where(controller:'asks')
  scope :answers,where(controller:'answers')
  scope :comments,where(controller:'comments')
  
  def verify!
    case controller
    when 'asks'
      Ask.real_create(self.body.with_indifferent_access,User.find(self.user_id))
    when 'answers'
      Answer.real_create(self.body.with_indifferent_access,User.find(self.user_id))
    when 'comments'
      Comment.real_create(self.body.with_indifferent_access,User.find(self.user_id))
    end
    self.delete
  end
end
