# -*- encoding : utf-8 -*-
module Ktv
  class IBeike
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def act!(params,value)
      u=nil
      msg=''
      ret = UCenter::IBeike.login('user',nil,{isuid:0,username:params[:user][:email],password:params[:user][:password]})
      status = ret['root']['item'][0].to_i
      suc_flag = false
      if status > 0
        u = nil
        u ||= User.where(ibeike_uid:status).first
        u ||= User.import_from_ibeike!(UCenter::IBeike.get_user('user',nil,{username:status,isuid:1}))
      elsif -1 == status
        msg='无此用户.'
      elsif -2 == status
        msg='密码错误.'
      elsif -3 == status
        msg='安全提问的回答错误.'
        #todo
      end
      return [u,msg]
    end
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


