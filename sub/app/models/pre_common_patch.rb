# -*- encoding : utf-8 -*-
class PreCommonPatch < ActiveRecord::Base
  include ActiveBaseModel
  self.table_name =  'pre_common_patch'
end
