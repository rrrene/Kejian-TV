class CnuCoursewares < ActiveRecord::Base
  self.table_name='coursewares';establish_connection :psvr_cnu_kejian
end
