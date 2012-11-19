# -*- encoding : utf-8 -*-
module Ktv
  class Renren
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def build_login_page
      @login_page = @agent.get("http://www.renren.com/")
      form = @login_page.form_with(:id=>'loginForm')
      ret = [form['origURL'], form['domain'], form['key_id'], form['captcha_type']]
      captcha = @agent.get 'http://icode.renren.com/getcode.do?t=web_login&rnd=Math.random()'
      ret << Base64::encode64(captcha.body)
      return ret
    end
    def send_login!(request,cookie,uniqueTimestamp,h)
      agent = request.nil? ? Setting.user_agent : request.env['HTTP_USER_AGENT']
      agent = Setting.user_agent if agent.blank?
      res = Ktv::JQuery.ajax({
        url:"http://www.renren.com/ajaxLogin/login?1=1&uniqueTimestamp=#{uniqueTimestamp}",
        type:'POST',
        accept:'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'COOKIE' => cookie,
        'User-Agent' => agent, 
        'Referer' => 'http://www.renren.com/',
        data:h,
        psvr_response_anyway: true
      })
      res
      # res values are like
      # => "{\"catchaCount\":0,\"code\":false,\"homeUrl\":\"http://www.renren.com/SysHome.do?origURL=http%3A%2F%2Fwww.renren.com%2Findexcon&catchaCount=0&failCode=512\",\"failDescription\":\"您输入的验证码不正确\",\"failCode\":512,\"email\":\"pmq2001\"}"
      # => "{\"code\":true,\"homeUrl\":\"http://www.renren.com/callback.do?t=eddd4481ac86d9e1f122eb80cae231cb3&origURL=http%3A%2F%2Fwww.renren.com%2Findexcon&needNotify=false\"}"
    end
    class << self
      def state_ok?(u)
        #检测登录有没有过期
        renren_cookies=u.renren_cookies
        rr = Ktv::Renren.new
        rr.agent.redirect_ok = :all
        rr.agent.cookie_jar.load_cookiestxt(StringIO.new(renren_cookies))
        page = rr.agent.get 'http://www.renren.com'
        parser = page.parser
        if parser.css('head script').text =~ /XN.user.id\s*=\s*['"](\d+)['"]/
          return true
        else
          return false
        end
      end
      def send_invitation(agent,user_id,renren_uids)
        u = User.find user_id
        renren_cookies=u.renren_cookies
        rr = Ktv::Renren.new
        rr.agent.redirect_ok = :all
        rr.agent.cookie_jar.load_cookiestxt(StringIO.new(renren_cookies))
        auth=u.getauth(:renren)
        me_rruid=auth.try(:[],'root').try(:[],'item').try(:[],1)
        renren_requestToken = renren__rtk = ''
        renren_uids.each do |to_id|
          if renren__rtk.blank? or renren_requestToken.blank?
            parser = page.parser
            if parser.css('head script').text =~ /get_check_x\s*:\s*['"]([^'"]+)['"]/
              renren__rtk = $1
            else
              Utils.assert(false)
            end
            if parser.css('head script').text =~ /get_check\s*:\s*['"]([^'"]+)['"]/
              renren_requestToken = $1
            else
              Utils.assert(false)
            end
          end
          data={}
          data['body'] = '来课件交流系统玩玩吧！'
          data['_rtk'] = renren__rtk
          data['requestToken'] = renren_requestToken
          data['only_to_me']='1'
          data['color']=''
          data['mode']='conversation'
          data['ref']="http://gossip.renren.com/"
          data['id'] = me_rruid
          data['cc'] = to_id
          res = Ktv::JQuery.ajax({
            url:'http://gossip.renren.com/gossip.do',
            type:'POST',
            :accept=>:json,
            'COOKIE' => rr.agent.cookies.join('; '),
            'User-Agent' => agent,
            'Referer' => "http://www.renren.com/#{to_id}/profile",
            data:data,
          })
            #todo 
            #=> {"code"=>1, "msg"=>"请先激活。"}
            #=> {"visiter":484892881,"hasReadRight":true,"admin":false,"guest":285692613,"code":0}
            #
          # sleep (30+rand*10).to_i
=begin
          res = Ktv::JQuery.ajax({
            url:'http://wpi.renren.com/comet_broadcast',
            type:'POST',
            :accept=>'*/*',
            :contentType=>:xml,
            'COOKIE' => rr.agent.cookies.join('; '),
            'User-Agent' => agent,
            'Referer' => "http://wpi.renren.com/wtalk/ime.htm?v=5",
            psvr_response_anyway: true,
            :data=>%Q{
              <sendlist>
              <message type="chat" from="#{me_rruid}@talk.renren.com" to="#{to_id}@talk.renren.com">
              <body>hi<body>
              <attachment></attachment>
              </message>
              </sendlist>
            },
          })
=end
        end
      end
      def psvr_update_cookies(u,rr)
        io = StringIO.new
        rr.agent.cookie_jar.dump_cookiestxt(io)
        io.rewind
        u.update_attribute(:renren_cookies,io.read)
      end
      def import_info(agent,renren_cookies,user_id,callback,guanzhu_ktv,fabiao_ktv,no_rescue=false)
        u = User.find user_id
        rr = Ktv::Renren.new
        u.update_attribute(:reg_extent,2)
        rr.agent.redirect_ok = :all
        renren_cookies.each do |key,value|
          cookie = Mechanize::Cookie.new(key, value)
          cookie.domain = ".renren.com"
          cookie.path = "/"
          rr.agent.cookie_jar.add!(cookie)
        end
        page = rr.agent.get callback
        parser = page.parser
        finally_suc = false
        begin
          res = Ktv::JQuery.ajax({
            url:'http://www.renren.com/getOtherAccounts',
            type:'GET',
            :accept=>:json,
            'COOKIE' => rr.agent.cookies.join('; '),
            'User-Agent' => agent,
            'Referer' => 'http://www.renren.com/',
            data:{
            },
          })
          if res['self_isPage']=='true'
            u.update_attribute(:reg_extent,3)
            # need to switch account
            renren__rtk = renren_requestToken = ''
            if parser.css('head script').text =~ /get_check_x\s*:\s*['"]([^'"]+)['"]/
              renren__rtk = $1
            else
              Utils.assert(false)
            end
            if parser.css('head script').text =~ /get_check\s*:\s*['"]([^'"]+)['"]/
              renren_requestToken = $1
            else
              Utils.assert(false)
            end

            res['otherAccounts'].each do |otherAccount|
              if otherAccount['isPage']=='false'
                res2 = Ktv::JQuery.ajax({
                  url:'http://www.renren.com/switchAccount',
                  type:'POST',
                  :accept=>:json,
                  'COOKIE' => rr.agent.cookies.join('; '),
                  'User-Agent' => agent,
                  'Referer' => 'http://www.renren.com/',
                  data:{
                    _rtk:renren__rtk,
                    destId:otherAccount['id'],
                    origUrl:'http://www.renren.com/',
                    requestToken:renren_requestToken,
                  },
                })
                page = rr.agent.get res2['url']
                parser = page.parser
                break
              end
            end
          end
          
          uid = ''
          u.update_attribute(:reg_extent,4)
          psvr_update_cookies(u,rr)
          if parser.css('head script').text =~ /XN.user.id\s*=\s*['"](\d+)['"]/
            uid = $1
          else
            Utils.assert(false)
          end
          # 好的，所以，@auth 是数组
          homepage = "http://www.renren.com/#{uid}"
          @auth = UCenter::ThirdPartyAuth.getauth(nil,{
            uid:uid,
            uc_uid:u.uid,
            provider:'renren',
            homepage: homepage,
            profilepage: "http://www.renren.com/#{uid}/profile",
            hardcore_succeeded:true
          })
          renren__rtk = renren_requestToken = ''
          u.update_attribute(:reg_extent,5)
          page = rr.agent.get homepage
          parser = page.parser
          if parser.css('head script').text =~ /get_check_x\s*:\s*['"]([^'"]+)['"]/
            renren__rtk = $1
          else
            Utils.assert(false)
          end
          if parser.css('head script').text =~ /get_check\s*:\s*['"]([^'"]+)['"]/
            renren_requestToken = $1
          else
            Utils.assert(false)
          end
          if fabiao_ktv
            u.update_attribute(:reg_extent,6)
            form = page.form_with(:class=>'status-global-publisher')
            form['_rtk'] = renren__rtk
            form['requestToken'] = renren_requestToken
            form['channel'] = 'renren'
            form['content'] = "成功绑定#{Setting.ktv_subname}课件交流系统账号。 http://#{Setting.ktv_subdomain}/users/#{u.id}"
            form.submit
            
            sleep 1
            form['comment'] = "成功绑定#{Setting.ktv_subname}课件交流系统账号。 http://#{Setting.ktv_subdomain}/users/#{u.id}"
            form['url'] = form['link'] =  "http://#{Setting.ktv_subdomain}/users/#{u.id}"
            form['meta'] = '%22%22'
            form['summary'] = Setting.introductions.join(' ')
            form['description'] = Setting.introductions.join(' ')
            form['thumbUrl'] = 'http://kejian.tv/thumb.jpg'
            form['title'] = "#{Setting.ktv_subname}课件交流系统 - #{u.name_beautified}"
            form['type'] = '6'
            form.action = "http://shell.renren.com/#{uid}/share?1"
            form.submit
          end
          if guanzhu_ktv
            u.update_attribute(:reg_extent,7)
            res = Ktv::JQuery.ajax({
              url:"http://page.renren.com/makefans",
              type:'POST',
              :accept=>:json,
              'COOKIE' => rr.agent.cookies.join('; '),
              'User-Agent' => agent,
              'Referer' => 'http://page.renren.com/601523545',
              data:{
                _rtk:renren__rtk,
                pid:'601523545',
                requestToken:renren_requestToken,
              },
            })
          end

          # 1. material
          u.update_attribute(:reg_extent,8)
          psvr_update_cookies(u,rr)
          material = u.sub_user_material
          material ||= u.build_sub_user_material
          page = rr.agent.get "http://www.renren.com/#{uid}/profile?v=info_ajax"
          parser = page.parser
          profile_summary = parser.css('.profile-summary').text.split(/\n+/)
          profile_summary.keep_if{|x| x.present?}
          profile_summary = profile_summary.map{|x| x.strip}
          0.upto(profile_summary.size/2).each do |i|
            iii = i*2
            jjj = i*2 + 1
            case(profile_summary[iii])
            when '所在学校:'
              material.school=profile_summary[jjj]
            when "生　　日:"
              date = Ktv::Utils.safely(nil){Date.parse jjj.gsub(/[^\d\-]+/,'')}
              material.birthday=Time.utc(date.year, date.month, date.day) if date
            when "星　　座:"
              material.astrological_sign=profile_summary[jjj]
            when  "家　　乡:"
              material.address_hometown=profile_summary[jjj]
            end
          end
          experiences = []
          parser.css('dl.info').each do |dl|
            i = 0
            while i < dl.children.count
              if 'dt'==dl.children[i].name
                iii=dl.children[i].text.strip
                i += 1
                while dl.children[i] and 'dd'!=dl.children[i].name and 'dt'!=dl.children[i].name
                  i += 1
                end
                if dl.children[i]
                  if 'dd'==dl.children[i].name
                    jjj = dl.children[i].text.strip
                    case iii
                    when '性别 :'
                      material.is_boy = ('男' == jjj)
                    when '生日 :'
                      date = Ktv::Utils.safely(nil){Date.parse jjj.gsub(/[^\d\-]+/,'')}
                      material.birthday=Time.utc(date.year, date.month, date.day) if date
                    when '家乡 :'
                      material.address_hometown=jjj
                    when '大学 :'
                      material.school_xueshixuewei=jjj
                    when '高中 :'
                      material.school_gaozhong=jjj
                    when '中专技校 :'
                      material.school_zhongzhuan=jjj
                    when '初中 :'
                      material.school_chuzhong=jjj
                    when '小学 :'
                      material.school_xiaoxue=jjj
                    when '公司 :'
                      if jjj.present?
                        experiences.delete_if{|x| x.kind_of?(Hash) and (x['name']==jjj || x[:name]==jjj)}
                        company = {name:jjj}
                        i += 1
                        while dl.children[i] and 'dd'!=dl.children[i].name and 'dt'!=dl.children[i].name
                          i += 1
                        end
                        if dl.children[i]
                          if 'dt'==dl.children[i].name and '时间 :'==dl.children[i].text.strip
                            i += 1
                            while dl.children[i] and 'dd'!=dl.children[i].name and 'dt'!=dl.children[i].name
                              i += 1
                            end
                            if dl.children[i]
                              if 'dd'==dl.children[i].name
                                company[:duration] = dl.children[i].text.strip
                              else
                                next
                              end
                            end
                          else
                            next
                          end
                        end
                        experiences << company
                      end
                    when 'QQ :'
                      material.im_qq = jjj
                    when 'MSN :'
                      material.im_msn = jjj
                    when '手机号 :'
                      material.phone_mobile = jjj
                    when '个人网站 :'
                      material.website_other = jjj
                    end
                  else
                    next
                  end                
                end
              end
              i += 1
            end
          end
          material.experiences = experiences
          parser.css('.userProfileItem').each do |item|
            iii = item.text.strip
            jjj = item.parent().css('.userProfileItemValue').text.strip
            case iii
            when "兴趣爱好 :"
              material.p_xingquaihao = jjj
            when "喜欢音乐 :"
              material.p_xihuanyinyue = jjj
            when "喜欢电影 :"
              material.p_xihuandianying = jjj
            when "玩的游戏 :"
              material.p_wandeyouxi = jjj
            when "喜欢动漫 :"
              material.p_xihuandongman =jjj
            when "玩的运动 :"
              material.p_wandeyundong = jjj
            when "喜欢书籍 :"
              material.p_xihuanshuji = jjj
            end
          end
          
          # 2. friends
          u.update_attribute(:reg_extent,9)
          page = rr.agent.get "http://friend.renren.com/myfriendlistx.do"
          parser = page.parser
          friends = parser.css('script').text 
          is_real_avatar = false
          if friends =~ /var\s+user\s*=\s*([^;]+);/
            material.renren_user = $1
            if $1.dup =~ /star\s*:\s*true/
              is_real_avatar = true
            end
          end
          if friends =~ /var\s+friends\s*=\s*([^;]+);/
            material.renren_friends = $1
          end

          # 3. avatars download script
          u.update_attribute(:reg_extent,10)
        
          material.avatars_renren = []
          page = rr.agent.get "http://photo.renren.com/getalbumprofile.do?owner=#{uid}"
          parser = page.parser
          got_current_avatar = false
          working_dir = File.expand_path("tmp_#{Rails.env}/avatar_workingdir/#{u.uid}",Rails.root)
          FileUtils.mkdir_p(working_dir)
          if tiny = parser.css('#commentEditorForm img.avatar').first
            tiny_avatar = tiny.attributes['src'].value
            tiny_filepath = "#{working_dir}/tiny_#{File.basename tiny_avatar}"
            puts cmd=%Q{curl "#{tiny_avatar}" > "#{tiny_filepath}"}
            puts `#{cmd}`
            o_avatar = ''
            o_filepath = ''
            parser.css('.photo-list a.picture img').each do |pic|
              if pic.attributes['data-photo'].value =~ /large:'([^']+)'/
                if !got_current_avatar and $1.split('_')[-1]==tiny_avatar.split('_')[-1]
                  # set current avatar
                  o_avatar=$1
                  o_filepath = "#{working_dir}/orig_#{File.basename o_avatar}"
                  got_current_avatar = true
                end
                material.avatars_renren << $1
              end
            end
            puts cmd=%Q{curl "#{o_avatar}" > "#{o_filepath}"}
            puts `#{cmd}`
            # puts `cp "#{tiny_filepath}" "#{working_dir}/up_small_#{File.basename tiny_avatar}"`
            puts `convert "#{tiny_filepath}" -resize 48x +repage -gravity North "#{working_dir}/up_small_#{File.basename tiny_avatar}"`
            puts `convert "#{o_filepath}" -resize 120x120^ -extent 120x120 -gravity center "#{working_dir}/up_middle_#{File.basename o_avatar}"`
            puts `convert "#{o_filepath}" -resize 200x200^ -extent 200x200 -gravity center "#{working_dir}/up_big_#{File.basename o_avatar}"`
            if is_real_avatar
              UCenter::User.rectavatar(nil,{
                uid: u.uid
              },{
                avatartype: 'real',
                avatar1:File.new("#{working_dir}/up_small_#{File.basename tiny_avatar}", 'rb'),
                avatar2:File.new("#{working_dir}/up_middle_#{File.basename o_avatar}", 'rb'),
                avatar3:File.new("#{working_dir}/up_big_#{File.basename o_avatar}", 'rb'),
              })
            end
            UCenter::User.rectavatar(nil,{
              uid: u.uid
            },{
              avatartype: 'virtual',
              avatar1:File.new("#{working_dir}/up_small_#{File.basename tiny_avatar}", 'rb'),
              avatar2:File.new("#{working_dir}/up_middle_#{File.basename o_avatar}", 'rb'),
              avatar3:File.new("#{working_dir}/up_big_#{File.basename o_avatar}", 'rb'),
            })
            FileUtils.rm_rf(working_dir)
          end

          # Last. save
          psvr_update_cookies(u,rr)
          u.update_attribute(:reg_extent,11)
          u.save(:validate=>false)
          finally_suc = true
        ensure
          unless finally_suc
            page = rr.agent.get callback
            if page.title =~ /解冻/
              u.update_attribute(:reg_extent,-1)
            else
              u.update_attribute(:reg_extent,0)
            end
          end
        end
      end
      
      def huanyizhang(request,cookie,rnd)
        agent = request.nil? ? Setting.user_agent : request.env['HTTP_USER_AGENT']
        agent = Setting.user_agent if agent.blank?
        res = Ktv::JQuery.ajax({
          url:"http://icode.renren.com/getcode.do?t=web_login&rnd=#{rnd}",
          type:'GET',
          accept:'image/png,image/*;q=0.8,*/*;q=0.5',
          'COOKIE' => cookie,
          'User-Agent' => agent, 
          'Referer' => 'http://www.renren.com/',
        })
        return "data:image/jpeg;base64,#{Base64::encode64(res)}"
      end

      def name_okay?(q)
        okay = true
        res = Ktv::JQuery.ajax({
          url:'http://reg.renren.com/AjaxRegisterAuth.do',
          type:'POST',
          accept:'text/plain',
          data:{
            "authType"=>"name",
            "rndval"=>Time.now.to_i.to_s,
            "t"=>Time.now.to_i.to_s,
            "value"=>q
          },
          psvr_response_anyway: true
        })
        okay = ('OKNAME'==res) if res.present?
        return okay
      end
    end
  end
end
