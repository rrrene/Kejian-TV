# -*- encoding : utf-8 -*-
class PsvrApp
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel  
  field :mysql_id
  field :item
end
