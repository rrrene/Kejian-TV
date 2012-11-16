# -*- encoding : utf-8 -*-
class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :has_read, :type => Boolean, :default => false
  field :target_id
  field :action

  # index :user_id
  # index :has_read
  
  belongs_to :log
  belongs_to :user, :inverse_of => :notifications
  
  scope :unread, where(:has_read => false) 
  
end
