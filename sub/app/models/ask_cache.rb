# -*- encoding : utf-8 -*-
class AskCache
  include Mongoid::Document
  # store_in :ask_caches,capped:true,size:10000  # 10000 = 127 records
  field :ask_id
  # index :ask_id,unique:true
  field :hot_rank
end
