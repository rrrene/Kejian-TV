# -*- encoding : utf-8 -*-
class Video
  include Mongoid::Document
  field :words,:type => Array,:default => []
  field :kejian1,:type => Hash,:default => {}
  field :url
  field :title
  field :video_set_id
  belongs_to :video_set
end

