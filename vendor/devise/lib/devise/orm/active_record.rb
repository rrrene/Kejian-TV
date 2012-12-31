# -*- encoding : utf-8 -*-
require 'orm_adapter/adapters/active_record'

ActiveRecord::Base.extend Devise::Models
