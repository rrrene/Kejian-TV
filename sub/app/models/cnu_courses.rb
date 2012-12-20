# -*- encoding : utf-8 -*-
class CnuCourses < ActiveRecord::Base
  self.table_name='courses';establish_connection :psvr_cnu_kejian
end
