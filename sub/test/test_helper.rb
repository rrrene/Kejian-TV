# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "sub_sub-test"
require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  $LOAD_PATH << "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'minitest/autorun'
  require "minitest/rails"
  require 'minitest/pride'
  require 'turn/autorun'


  Turn.config.format = :pretty


  module MiniTest
    module Rails
      module ActionController
        class TestCase
          include Devise::TestHelpers
          def denglu!(u)
            sign_in(u)
            @controller.sign_in_others
          end
        end
      end
    end
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  redis_connect!
end
