# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "sub_sub-test"
require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'turn/autorun'
require 'minitest/pride'
require 'capybara/rails'
require "capybara/dsl"
class IntegrationTest < MiniTest::Unit::TestCase
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  include Devise::TestHelpers
  def denglu!(user)
    sign_in(user)
    sing_in_others
  end
end

Turn.config.format = :outline
