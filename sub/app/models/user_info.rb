# -*- encoding : utf-8 -*-
class UserInfo
  include Mongoid::Document
  field :user_id
  Ktv::Consumers.keys.each do |key|
    field key.to_sym
  end
  def self.user_id_find_or_create(user_id,info={})
    item = self.where(user_id:user_id).first
    item ||= self.new
    item.user_id = user_id
    info.each do |key,value|
      item.send("#{key}=",value)
    end
    item.save!
    item
  end
end

