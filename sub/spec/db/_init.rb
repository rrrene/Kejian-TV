# -*- encoding : utf-8 -*-
require "rubygems"
require "bundler/setup"

require 'ostruct'
require 'active_support/core_ext'
module Redis
  module Search;end
end
require File.expand_path("../../../app/models/base_model.rb",__FILE__)
