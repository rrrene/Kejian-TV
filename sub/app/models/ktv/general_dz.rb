# -*- encoding : utf-8 -*-
module Ktv
  class GeneralDZ
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def act!(params,provider,value,request)
      u=nil
      msg=''
      data={
        fastloginfield: 'username',
        handlekey: 'ls',
        password:  params[:user][:password],
        quickforward: 'yes',
        username:  params[:user][:email],
      }
      res = Ktv::JQuery.ajax({
        psvr_original_response: true,
        url:"http://#{value[:addr]}/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1",
        type:'POST',
        data:data,
        psvr_response_anyway: true
      })
      res.cookies.each do |key,val|
        cookie = Mechanize::Cookie.new(key, val)
        cookie.domain = value[:cookie_domain]
        cookie.path = "/"
        @agent.cookie_jar.add!(cookie)
      end
      res = res.force_encoding_zhaopin
      if res=~/errorhandle_ls\s*\(\s*('([^']+)'|"([^"]+)")/
        msg = $2.dup
        msg = $3.dup if msg.blank?
      elsif res=~/succeedhandle_ls\(.*['"]uid['"]\s*:\s*('(\d+)'|"(\d+)").*\)/
        page=@agent.get("http://#{value[:addr]}/home.php?mod=spacecp&ac=profile&op=contact")
        parser = page.parser
        uidstr = $2.dup
        uidstr = $3.dup if uidstr.blank?
        # 好的，所以，如果UCenter找到了这个人，那么@auth 是数组
        @auth = UCenter::ThirdPartyAuth.getauth(request,{uid:uidstr,provider:provider,oauth_succeeded:true}).try(:[],'root').try(:[],'item')
        if @auth
          # 那么，在这个点上
          # 如果用户以前从来没有来过这个子站
          # 那么将被创建，用户资料是从uc那边搞到手的
          @user = User.find_by_uid(@auth[0])
        end
        if !@auth or !@user
          @user = User.new
          # 好的，所以，那么如果没找到呢？是个Hash！！！
          @auth = {
            :provider => provider,
            :uid => uidstr,
          }
          if res=~/succeedhandle_ls\(.*['"]username['"]\s*:\s*('([^']+)'|"([^"]+)").*\)/
            namestr = $2.dup
            namestr = $3.dup if namestr.blank?
            @user.name = namestr
          end
          if parser.css('#td_sightml').text=~/^([^()（）]+)/
            email = $1.strip.gsub("\u00A0",'')
            @user.email=email
            info0=UCenter::User.get_user(request,{username:@user.email,isemail:1})
          else
            info0='0'
          end
          @user.name_unknown = @user.errors[:name].present?
          if '0'==info0
            @user.fill_in_unknown_email
            ret = UCenter::User.register(request,{
              username:@user.slug,
              password:'psvr_password_unknown',
              email:@user.email,
              regip:request.ip,
              psvr_force:'1'
            })
            if ret.xi.to_i>0
              @user.uid=ret.xi.to_i
              @user.valid?
              @user.save(:validate=>false)
              # 好的！在这一点上，我们就可以往UC那边写入真正的auth了！
              UCenter::ThirdPartyAuth.getauth(request,{uc_uid:@user.uid.to_s,uid:@auth[:uid],provider:@auth[:provider],will_create:true,oauth_succeeded:true})
            else
              raise '注册UC同步注册错误！！！猿快来看一下！'
            end
          else
            p info0
            @user = User.import_from_dz!(info0)
            @user.ua(:name,namestr) if namestr.present?
          end
        end
        if !@user
          raise ScriptNeedImprovement 
        end
        u=@user
        msg=''
      else
        raise ScriptNeedImprovement 
      end
      return [u,msg]
    end
  end
end

