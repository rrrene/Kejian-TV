# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require "minitest/autorun"
require 'minitest/pride'
require "capybara/rails"
require "active_support/testing/setup_and_teardown"
require 'database_cleaner'
require 'ffaker'
require 'factory_girl'


# Faker::Name.name => "Christophe Bartell"
# Faker::Internet.email => "kirsten.greenholt@corkeryfisher.info"
FactoryGirl.find_definitions
DatabaseCleaner[:mongoid].strategy = :truncation
DatabaseCleaner.logger = Rails.logger
class MiniTest::Unit::TestCase
  include FactoryGirl::Syntax::Methods
  include MiniTest::Assertions
  def setup
    DatabaseCleaner.start
  end
  def teardown
    DatabaseCleaner.clean
  end
end

class MiniTest::Spec
  include FactoryGirl::Syntax::Methods
  include ActiveSupport::Testing::SetupAndTeardown
  alias :method_name :__name__ if defined? :__name__
  def build_message(*args)
    args[1].gsub(/\?/, '%s') % args[2..-1]
  end
end

class IntegrationTest < MiniTest::Spec
  include Rails.application.routes.url_helpers
  include Capybara::DSL
  register_spec_type(/Integration$/,self)
end

class HelperTest < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
  register_spec_type(/Helper$/,self)
end

class ControllerTest < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionController::TestCase::Behavior
  include Devise::TestHelpers
  include Rails.application.routes.url_helpers
  def self.determine_default_controller_class(name)
    if name.match(/.*(?:^|::)(\w+Controller)/)
      $1.safe_constantize
    else
      super(name)
    end
  end

  before do
    @controller = self.class.name.match(/((.*)Controller)/)[1].constantize.new
    @routes = Rails.application.routes
  end

  subject do
    @controller
  end
  MiniTest::Spec.register_spec_type( /Controller$/, self )
end


Turn.config.format = :outline
