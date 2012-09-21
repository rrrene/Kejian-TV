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
  Ktv::Consumers.values.each do |value|
    config.omniauth value[0], value[1], value[2]
  end

end
