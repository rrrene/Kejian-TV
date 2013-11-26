# -*- encoding : utf-8 -*-
class VideoSet
  include Mongoid::Document
  field :url
  field :title
  field :kejian1,:type => Hash,:default => {}
  field :videos_count, :type => Integer, :default => 0
  field :desc
  has_many :videos
end

