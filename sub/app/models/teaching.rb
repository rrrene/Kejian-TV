class Teaching
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :course
  embeds_many :teaching_klasses
  field :teacher
  field :credit
  field :judge
end
