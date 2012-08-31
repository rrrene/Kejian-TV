# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.


key = (Rails.env.development? ?  "_ktv_#{Setting.ktv_sub}_local_session" : "_ktv_#{Setting.ktv_sub}_session")
domain = (Rails.env.development? ?  "#{Setting.ktv_sub}.kejian.lvh.me" : "#{Setting.ktv_sub}.kejian.tv")

Sub::Application.config.session_store :cookie_store, 
                                      :key => key,
                                      :domain => domain,
                                      :expire_after => 30.minutes

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Sub::Application.config.session_store :active_record_store
