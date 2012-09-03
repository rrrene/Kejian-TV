# -*- encoding : utf-8 -*-
Sub::Application.configure do
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  # config.log_tags = [ :subdomain, :uuid ]
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)
  # Settings specified here will take precedence over those in config/application.rb
  config.active_support.deprecation = :notify
  config.i18n.fallbacks = true  
  # Code is not reloaded between requests
  config.cache_classes = true
  config.cache_store = :dalli_store, 'localhost'
      { :namespace => "ktv_#{Rails.env}", :expires_in => 1.day, :compress => true }
  
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true #false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => 'smtp.gmail.com',
    :port                 => 587,
    :domain               => 'kejian.tv',
    :user_name            => 'kejian.tv@gmail.com',
    :password             => 'jknlff8-pro-17m7755',
    :authentication       => 'plain',
    :enable_starttls_auto => true  
  }
  Mongoid.configure do |config|
    config.logger = nil
  end
  # assets___________
  config.assets.manifest = "/home/main/ktv/_assets_sub"
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.assets.debug = false
  config.assets.digest = true
  config.assets.compile = false
  config.assets.compress = true
  config.assets.css_compressor = 'sass-rails'
  config.assets.js_compressor = :uglifier
  config.assets.precompile += ['pre_application.css','for_help/application.js','for_help/application.css','for_help/cpanel.js','for_help/cpanel.css','for_help/topics.js','for_help/html5.js','for_help/cpanel_oauth.css','for_help/cpanel_oauth.js','for_help/validationEngine.js','for_help/keditor/kindeditor.js']
  # 别忘了同时修改:
  # config/initializers/z_ktv.rb
  config.action_controller.asset_host = 'http://ktv-intrinsic-sub.b0.upaiyun.com'
  config.assets.prefix = ''
  # assets-----------
  config.action_mailer.raise_delivery_errors = false
end
