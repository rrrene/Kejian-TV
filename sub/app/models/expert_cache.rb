# -*- encoding : utf-8 -*-
class ExpertCache
  include Mongoid::Document
  field :tag
  field :experts, :type => Array, :default => []
  # index :tag,unique:true
end
