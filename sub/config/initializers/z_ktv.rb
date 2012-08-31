# -*- encoding : utf-8 -*-
module Ktv
  class << self
    attr_reader :config
  end
  # self.configure{} 这种配置方法是可重入的
  # 因此不必保证一次性就全部配置完成
  # 以后可以随时修改配置
  @config = OpenStruct.new
  def self.configure
    yield(@config)
  end
end


module UCenter
  class << self
    attr_reader :config
  end
  @config = {}
  def self.define(k,v)
    @config[k]=v
  end
  def self.getdef(k)
    @config[k]
  end
end

module Discuz
  class << self
    attr_reader :cookiepre
    attr_reader :cookiepath
    attr_reader :cookiedomain
    attr_reader :cookiepre_real
  end
  @cookiepre = Setting.dz_cookiepre;
  @cookiedomain = Setting.ktv_subdomain;
  @cookiepath = Setting.dz_cookiepath;
  @cookiepre_real = @cookiepre+Digest::MD5.hexdigest(@cookiepath+'|'+@cookiedomain)[0...4]+'_'
end



UCenter.define('UC_CLIENT_RELEASE', '20110501')
UCenter.define('UC_APPID', '5');
UCenter.define('UC_KEY', 'af64HZPlY/1RdaOe4UftTp3XO+kQwB9f5SBojhc=');
unless Rails.env.development?
  UCenter.define('UC_API', 'http://uc.kejian.tv');
else
  UCenter.define('UC_API', 'http://uc.kejian.lvh.me');
end


Ktv.configure do |config|
  unless Rails.env.development?
    config.asset_host = 'http://ktv-intrinsic.b0.upaiyun.com'
  else
    config.asset_host = ''
  end
  config.redis = Redis::Search.config.redis
  config.consultants = [Ktv::Baidu,Ktv::Google]
  config.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.ktv.log",File::WRONLY|File::APPEND)
  config.google_simple_api_key = 'AIzaSyBlxza4_3kcy8jzeAwWZOiIO4qAJl607FY'
  %w{user_agent
     open_timeout
     read_timeout
     idle_timeout
     mechanize_per_page
     timeout
     proxy}.each do |item|
    config.send(:"#{item}=",Setting.send(item))
  end
  config.upyun_username = "pmq20"
  config.upyun_password = 'jknlff8-pro-17m7755'
  config.upyun_bucket = "ktv-pic"
  config.upyun_api_host = 'http://v0.api.upyun.com'
  config.upyun_bucket_domain = "http://ktv-pic.b0.upaiyun.com"
  config.school_new = Time.new(Setting.school_new[0],Setting.school_new[1],Setting.school_new[2])
  config.school_exam = Time.new(Setting.school_exam[0],Setting.school_exam[1],Setting.school_exam[2])
  config.school_over = Time.new(Setting.school_over[0],Setting.school_over[1],Setting.school_over[2])
end





# c.f. /usr/local/lib/ruby/gems/1.9.1/gems/actionpack-3.2.6/lib/sprockets/helpers/rails_helper.rb  Line: 53/173:0                                                                    
module Sprockets
  module Helpers
    module RailsHelper
      alias_method :asset_path_before_psvr,:asset_path
      def asset_path(source, options = {})
        ret = asset_path_before_psvr(source, options)
        if ret.starts_with?('///')
          ret[2..-1]
        else
          ret
        end
      end
    end
  end
end

