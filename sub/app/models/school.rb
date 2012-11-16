# -*- encoding : utf-8 -*-
class School
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  field :name
  field :coursewares_count, :type => Integer, :default => 0
  has_many :users
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :users_count;'老师数'
    when :name;'学校名'
    when :name_en;'学校英文名'
    when :slug;'学校的友好资源标识号'
    else
      COMMON_HUMAN_ATTR_NAME[attr].present? ? COMMON_HUMAN_ATTR_NAME[attr] : attr.to_s
    end
  end
  
end
