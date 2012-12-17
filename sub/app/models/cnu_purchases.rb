class CnuPurchases < ActiveRecord::Base
  self.table_name='purchases';establish_connection :psvr_cnu_kejian
end
