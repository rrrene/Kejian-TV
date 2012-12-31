# -*- encoding : utf-8 -*-
require 'orm_adapter/adapters/mongoid'

Mongoid::Document::ClassMethods.send :include, Devise::Models
