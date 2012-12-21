module Ktv
  class GeneralDZ
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def act!(params,value)
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
      elsif res=~/succeedhandle_ls/
        page=@agent.get("http://#{value[:addr]}/home.php?mod=spacecp&ac=profile&op=contact")
        parser = page.parser
        binding.pry
        parser.css('#td_sightml')
      else
        raise ScriptNeedImprovement 
      end
      return [u,msg]
    end
  end
end

