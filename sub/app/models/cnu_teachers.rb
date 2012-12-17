class CnuTeachers < ActiveRecord::Base
  self.table_name='teachers';establish_connection :psvr_cnu_kejian
end
