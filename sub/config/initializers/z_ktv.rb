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
  def self.in_out(m,a,request,opts={})
    opts ||= {}
    agent = request.nil? ? Setting.special_agent : request.env['HTTP_USER_AGENT']
    return Ktv::JQuery.ajax({
      :url => "#{UCenter.getdef('UC_API')}/index.php",
      :type => 'POST',
      :accept => :xml,
      'User-Agent' => agent, 
      :data => {
        m: m,
        a: a,
        inajax: '2',
        release: UCenter.getdef('UC_CLIENT_RELEASE'),
        input: UCenter::Php.uc_api_input2(agent,opts),
        appid: UCenter.getdef('UC_APPID'),
      },
      :psvr_response_anyway => true
    })
  end
  def self.in_out_ibeike(m,a,request,opts={})
    opts ||= {}
    agent = request.nil? ? Setting.special_agent : request.env['HTTP_USER_AGENT']
    return Ktv::JQuery.ajax({
      :ibeike_special_treatment=>true,
      :url => "http://uc.ibeike.com/index.php",
      :type => 'POST',
      :accept => :xml,
      'User-Agent' => agent, 
      :data => {
        m: m,
        a: a,
        inajax: '2',
        release: UCenter.getdef('UC_CLIENT_RELEASE'),
        input: UCenter::Php.uc_api_input2(agent,opts,'80bbjEemIom8QRUAn7ZgsTEcOOXcbH242tAIcUU'),
        appid: '8',
      },
      :psvr_response_anyway => true
    })
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
UCenter.define('UC_APPID', Setting.uc_appid);
UCenter.define('UC_KEY', Setting.uc_key);
if $psvr_really_development
  UCenter.define('UC_API', 'http://uc.kejian.lvh.me');
else
  UCenter.define('UC_API', 'http://uc.kejian.tv');
end

Ktv.configure do |config|
  config.redis = Redis::Search.config.redis
  config.consultants = [Ktv::Baidu,Ktv::Google]
  config.logger = Logger.new("#{Rails.root}/log_#{Rails.env}/ktv.log",File::WRONLY|File::APPEND)
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
  # logo_info = `identify "#{Rails.root}/app/assets/images/logo_ktv_#{Setting.ktv_sub}.png"`
  # if logo_info=~/PNG (\d+)x(\d+)/
  #   config.logo_ktv_width = $1.to_i
  #   config.logo_ktv_height = $2.to_i
  # end
  # logo_info = `identify "#{Rails.root}/app/assets/images/logo_#{Setting.ktv_sub}.png"`
  # if logo_info=~/PNG (\d+)x(\d+)/
  #   config.logo_width = $1.to_i
  #   config.logo_height = $2.to_i
  # end
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




def log_connect!(index=0)
  logger_dirpath="#{Rails.root}/log_#{Rails.env}"
  Rails.logger = Logger.new("#{logger_dirpath}/rails.#{index}.log", File::WRONLY | File::APPEND)

  ActiveSupport::LogSubscriber.logger = Rails.logger
  ActionController::Base.logger = Rails.logger
  ActionMailer::Base.logger = Rails.logger
  ActiveResource::Base.logger = Rails.logger
  Rails.application.assets.logger = Rails.logger
  Tire.configure do
    logger "#{logger_dirpath}/tire.#{index}.log"
  end

  Ktv.config.logger = Logger.new("#{logger_dirpath}/ktv.#{index}.log",File::WRONLY|File::APPEND)
  $debug_logger = Logger.new("#{logger_dirpath}/debug.#{index}.log", File::WRONLY | File::APPEND)

end

log_connect! unless $im_running_under_unicorn

