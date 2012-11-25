# -*- encoding : utf-8 -*-
module ActiveBaseModel
  extend ActiveSupport::Concern
  included do
    scope :nondeleted,where('displayorder >= 0')
  end
  module ClassMethods
    def elastic_search_psvr_index_name
      if $psvr_really_testing
        return "#{self.table_name}_test"
      elsif $psvr_really_development
        return "#{self.table_name}_dev"
      else
        return self.table_name
      end
    end
  end
end
