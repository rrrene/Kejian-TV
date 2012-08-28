class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
end
