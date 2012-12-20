# -*- encoding : utf-8 -*-
class CnuInstitutes < ActiveRecord::Base
  self.table_name='institutes';establish_connection :psvr_cnu_kejian
end
