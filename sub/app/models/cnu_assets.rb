class CnuAssets < ActiveRecord::Base
  self.table_name='assets';establish_connection :psvr_cnu_kejian
end
