# -*- encoding : utf-8 -*-
module Ktv
  class Discuz
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def slight_touch
      @page = @agent.get("http://#{Setting.ktv_subdomain}/simple/forum.php")
    end
    def login!(username,password)
      # 依赖于forum.php显示登陆框框
      @login_page = @agent.get("http://#{Setting.ktv_subdomain}/simple/forum.php")
      form = @login_page.form_with(:id=>'lsform')
      if form
        form.username = username
        form.password = password
        @page = form.submit
      end
    end
    def activate_user!
      # 必须在login!后立即调用我
      if form = @page.form_with(:id=>'registerform')
        @page = form.submit
        return true
      else
        puts "#{@page.parser.css('#um .vwmy').to_s} -- nothing to do"
        return nil
      end
    end
  end
end

