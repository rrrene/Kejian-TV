# -*- encoding : utf-8 -*-
class Airule
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :cw_id
  field :user_name 
  field :choices,:type =>Array,:default => []
  field :rules,:type => Array,:default=>[]
  field :sortstr,:type =>String
  field :file_type,:type=>String
  field :accepted,:type =>Boolean,:default => true

end
