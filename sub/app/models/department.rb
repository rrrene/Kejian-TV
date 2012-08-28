class Department
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  field :name
end
