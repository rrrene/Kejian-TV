require 'rubygems'
require 'rspec'
require 'rspec/autorun'
require 'rails'
require 'active_record'
require "carrierwave"
require 'carrierwave/orm/activerecord'
require 'carrierwave/processing/mini_magick'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "carrierwave-grandcloud"


module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split('/')[0..-3].join('/'),"spec"].join("/")
    end
  end
end

ActiveRecord::Migration.verbose = false

# 测试的时候需要修改这个地方
CarrierWave.configure do |config|
  config.storage = :grandcloud
  config.grandcloud_access_id = "20RGC3KJUK0NV"
  config.grandcloud_access_key = 'MzgyM2EwYTMtMzcwYi00ODM2'
  config.grandcloud_bucket = "carrierwave"
  config.grandcloud_location = "huabei-1"
end

def load_file(fname)
  File.open([Rails.root,fname].join("/"))
end