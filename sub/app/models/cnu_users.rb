# -*- encoding : utf-8 -*-
class CnuUsers < ActiveRecord::Base
  self.table_name='users';establish_connection :psvr_cnu_kejian
end
