# -*- encoding : utf-8 -*-
module Ktv
  class Uc
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def login!(username='kejian.tv',password='jknlff8-pro-17m7755')
      # 依赖于forum.php显示登陆框框
      @login_page = @agent.get("http://uc.#{Setting.short_domain}/admin.php?m=user&a=login&iframe=&sid=forum.php")
      form = @login_page.form_with(:id=>'loginform')
      form.radiobuttons_with(:id=>'admin')[0].check
      if form
        form.username = username
        form.password = password
        @page = form.submit
      end
    end
    def get_ids(slug)
        url="http://#{slug}.#{Setting.short_domain}"
        page=@agent.get('/admin.php?m=app&a=ls')
        p=page.parser
        uc_simpleappid=''
        uc_appid=''
        uc_key=''
        p.css('tr').each{|x|
          unless x.css("a[href='#{url}/simple']").empty?
            if x.css('a')[0].attributes['href'].value=~/appid=(\d+)/
              uc_simpleappid=$1
            end
            break
          end
        }
        p.css('tr').each{|x|
          unless x.css("a[href='#{url}']").empty?
            page=@agent.get x.css('a')[0].attributes['href'].value
            if page.filename=~/appid=(\d+)/
              uc_appid=$1.dup
            end
            uc_key=page.forms[0]['authkey']
            break
          end
        }
        return [uc_simpleappid,uc_appid,uc_key]
    end
    def create_app(name,url)
      page=@agent.get('/admin.php?m=app&a=add')
      if form = page.forms[1]
        form['name']=name
        form['url']=url
        page = form.submit
        return true
      else
        raise 'no form found'
      end
    end
  end
end

