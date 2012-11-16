# -*- encoding : utf-8 -*-
module Ktv
  class IBeike
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def login!(username='richarddan',password='920316qwaguan')
      # 依赖于forum.php显示登陆框框
      @login_page = @agent.get("http://city.ibeike.com/logging.php?action=login")
      form = @login_page.form_with(:id=>'loginform')
      if form
        form.username = username
        form.password = password
        @page = form.submit
      end
      @login_page = @agent.get("http://city.ibeike.com/admincp.php")
      form = @login_page.form_with(:id=>'loginform')
      if form
        form.admin_password = password
        @page = form.submit
      end
      @dz = DiscuzAdmin.new
      @dz.start_mode('ibeike')
    end
    def import_user(uid)
      @user=User.where(:ibeike_uid=>uid).first
      @page = @agent.get "http://city.ibeike.com/admincp.php?action=members&operation=edit&uid=#{uid}"
      form = @page.forms.first
      @dz_page = @dz.fill_user_info(@user.uid,form)
    end
  end
end


