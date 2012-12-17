class CnuSchemaMigrations < ActiveRecord::Base
  self.table_name='schema_migrations';establish_connection :psvr_cnu_kejian
end
