# -*- encoding : utf-8 -*-
module Ktv
  class Xunlei
    XUNLEI_URL2INFO = 'http://i.vod.xunlei.com/req_get_method_vod'
    REQ_SCREENSHOT = 'http://i.vod.xunlei.com/req_screenshot'
    USERS = [
      {"isvip" => "2","userid" => "38393586","sessionid" => "3BCA907F95640B0F3D8C7E7D958575D3DF4479F5A3F199E9A67300699F20732B9F61749F8F1618745D84E40BB358CE5904835EAF2DE417C0A481422F7A4E62DD"},
      {"isvip"=>"5","userid"=>"87642079","sessionid"=>"3BCA907F95640B0F3D8C7E7D958575D3DF4479F5A3F199E9A67300699F20732B9F61749F8F1618745D84E40BB358CE5904835EAF2DE417C0A481422F7A4E62DD"},
      # {"isvip" => "1","userid" => "pmq2001","sessionid" => "F3B1755E71D821CADAC916D9AB09221A92008399ACC9F8B74F63FD37A0BB8F82DF561E0C1175CB33752E62C64E3E5F477554ABDAE31F443C90ADC60331F519FB"}
    ]
    def self.give_me_a_user
      USERS[rand(USERS.size)]
    end
    def self.xunlei_url2info(url)
      user = self.give_me_a_user
      response = JQuery.ajax(:type => 'GET',
        :url => XUNLEI_URL2INFO,
        :data => {
          :ver => '2.721',
          :userid => user['userid'],
          :vip => user['isvip'],
          :sessionid => user['sessionid'],
          :url => url,
          :platform => '0',
          :cache => (Time.now.to_f*1000).to_i.to_s,
          :from => 'xlpan_default'
        }
      )
      return {} if response.nil?
      ret = Utils.safely{response['resp']}
      return {} if ret.blank?
      ret
    end
    def self.gcid2screenshot(gcid)
      response = JQuery.ajax(:type => 'GET',
        :url => REQ_SCREENSHOT,
        :data => {
          :req_list => gcid
        }
      )
      return {} if response.nil?
      ret = Utils.safely{response['resp']}
      return {} if ret.blank?
      ret
    end
  end
end
