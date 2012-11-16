# -*- encoding : utf-8 -*-
class LoginLog
  include Mongoid::Document
    
  field :user_id
  field :login_at
  field :range
    
end
