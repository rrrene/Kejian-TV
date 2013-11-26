# -*- encoding : utf-8 -*-
class PreCommonUsergroup < ActiveRecord::Base
  include ActiveBaseModel
  self.table_name =  'pre_common_usergroup'
  def self.inheritance_column
    'inheritance_type'
  end
end
