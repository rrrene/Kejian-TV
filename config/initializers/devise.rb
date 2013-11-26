# -*- encoding : utf-8 -*-
# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  config.mailer_sender = Setting.email_sender
  require 'devise/orm/mongoid'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.sign_out_via = :delete
  config.remember_for = 2.weeks
  config.reconfirmable = true
  config.maximum_attempts = 888
  config.reset_password_within = 6.hours
  config.omniauth Ktv::Consumers[:renren][:oauth][0], Ktv::Consumers[:renren][:oauth][1], Ktv::Consumers[:renren][:oauth][2]
  config.timeout_in = 2592000
=begin
被注掉的原因是，在子站，我们不想让用户有太多的第三方网站登录选择。
其实我们只想让他们从人人过来。因为大学生基本上都有人人！
  Ktv::Consumers.values.each do |value|
    next unless value[:oauth].present?
    config.omniauth value[:oauth][0], value[:oauth][1], value[:oauth][2]
  end
=end
end
# fix by psvr
# to workaround renren's redirect restrictions
OmniAuth.config.full_host="http://#{Setting.ktv_subdomain}"
