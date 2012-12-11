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
  config.filter_parameters = []

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  config.action_mailer.delivery_method = :smtp
  smtp_settings = {
    :address              => 'smtp.mandrillapp.com',
    :port                 => 587,
    :user_name            => 'pmq2001',
    :password             => '99747048-b116-40cb-a4b6-4e7629d920b0',
  }
  config.action_mailer.smtp_settings = smtp_settings
  config.middleware.use ExceptionNotifier,
    :email_prefix => "[#{Setting.ktv_sub.upcase}抛出了异常] ",
    :sender_address => %{"Kejian.TV" <kejian.tv@gmail.com>},
    :exception_recipients => %w{pmq2001@gmail.com llb0536@gmail.com},
    :smtp_settings => smtp_settings
  Mongoid.logger = nil
  Moped.logger = nil
  # assets___________
  config.assets.manifest = "/home/main/ktv/_assets_sub"
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.assets.debug = false
  config.assets.digest = true
  config.assets.compile = false
  config.assets.compress = true
  config.assets.css_compressor = 'sass-rails'
  config.assets.js_compressor = :uglifier
  config.assets.precompile += %w{
    __dz_forum_modcp.css
    bind/__rr.css
    __lnk_app.css
    jia.css
    __lnk_popup.css
    __g.css
    __lnk.css
    __lnk_reg.css 
    qua_7d84bd7ff4616c9b.css
    qua_f791fcfc8935e1ad.css
    qua_06b596594fbe5bcf.css
    ktv/embed.js
    ktv/upload.js
    ui_orig.js
    modernizr.js
    pre_application.js
    pre_application.css
    for_help/application.js
    for_help/application.css
    for_help/cpanel.js
    for_help/cpanel.css
    for_help/topics.js
    for_help/html5.js
    for_help/cpanel_oauth.css
    for_help/cpanel_oauth.js
    for_help/validationEngine.js
    for_help/keditor/kindeditor.js
    for_help/jquery.tipsy.js
    jquery.tipsy.css
    ktv/__ytb.css
    ktv/ie.css
    ktv/__flo.css
    ktv/ie7.css
    ktv/ie6.css
    css_ie.css
    jquery.ui.autocomplete.js
    ktv/ie/application.js
    ktv/ie/application.css
    ktv/embed.js
    ktv/ppt.css
    ktv/player_ppt.js
    ktv/s.player.js
    ktv/ie.css
    ktv/ie7.css
    ktv/ie6.css
    ktv/__zm.css
    ktv/__zm_reg.css
    ktv/__zm_sur.css
    ktv/__zm_hoth.css
    ktv/__zm_ban.css
    ktv/__zm_dar.css
    ktv/__zm_user.css
    ktv/__zm_friend.css
    ktv/__zm_dialog.css
    ktv/__kug.css
    ktv/__ytb.css
    ktv/__ytb_contract.css
    ktv/__ytb_dashboard.css
    ktv/__ytb_manager.css
    ktv/__ytb_playlists.css
    ktv/__sdk.css
    ktv/__qua.css
    ktv/__zm_user.css
    ktv/__ytb_playlists_show.css
    ktv/__slide.css
    ktv/__slide_fb.css
    ktv/__slide_pro.css
    ktv/__slide_plan.css
    ktv/__ytb_min_ql.css
    ktv/__ytb_upload.css
    kinetic-v4.0.0.js

    cpanel.js
    cpanel.css
    topics.js
    html5.js
    cpanel_oauth.css
    cpanel_oauth.js
    validationEngine.js
    ktv/swfupload.js
    keditor/*
    about.css
    css_ie.css
    jquery.autocomplete.js
    jquery.ui.autocomplete.js
    
    ktv/jquery.contextMenu.js
    ktv/jquery.contextMenu.css    
  }.uniq
  # 别忘了同时修改:
  # config/initializers/z_ktv.rb
  config.action_controller.asset_host = 'http://ktv-intrinsic-sub.b0.upaiyun.com'
  config.assets.prefix = ''
  # assets-----------
  config.action_mailer.raise_delivery_errors = false
  $psvr_really_production = true
end
Mongoid.raise_not_found_error=false
