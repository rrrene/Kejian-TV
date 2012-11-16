# -*- encoding : utf-8 -*-
module ActiveBaseModel
  extend ActiveSupport::Concern
  included do
    scope :nondeleted,where('displayorder >= 0')
  end
end
