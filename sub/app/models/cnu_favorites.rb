# -*- encoding : utf-8 -*-
class CnuFavorites < ActiveRecord::Base
  self.table_name='favorites';establish_connection :psvr_cnu_kejian
end
