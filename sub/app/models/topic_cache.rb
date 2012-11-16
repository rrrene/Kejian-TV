# -*- encoding : utf-8 -*-
class TopicCache
  include Mongoid::Document
  # store_in :topic_caches,capped:true,size:100000  # 10000 = 127 records
  field :name
  field :followers_count
  field :hot_rank
  # index :name
  def as_json(opts={})
    {id:self.id,name:self.name,followers_count:self.followers_count}
  end
end
