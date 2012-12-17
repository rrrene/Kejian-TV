class CnuTeachings < ActiveRecord::Base
  self.table_name='teachings';establish_connection :psvr_cnu_kejian
end
