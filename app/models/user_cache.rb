# -*- encoding : utf-8 -*-
class UserCache
  include Mongoid::Document
  # store_in :user_caches,capped:true,size:100000  # 10000 = 127 records
  field :id
  field :followers_count
  field :hot_rank
  # index :id
  # index :hot_rank
  def as_json(opts={})
    {id:self.id,name:self.name,followers_count:self.followers_count}
  end
  def user
    User.find(self.id)
  end
end
