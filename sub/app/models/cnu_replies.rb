# -*- encoding : utf-8 -*-
class CnuReplies < ActiveRecord::Base
  self.table_name='replies';establish_connection :psvr_cnu_kejian
end
