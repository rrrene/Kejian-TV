# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.


if $psvr_really_development
  key = "_ktv_#{Setting.ktv_sub}_local_session"
elsif $psvr_really_testing
  key = "_ktv_#{Setting.ktv_sub}_test_session"
else
  key = "_ktv_#{Setting.ktv_sub}_session"
end
domain = Setting.ktv_subdomain

Sub::Application.config.session_store :cookie_store, 
                                      :key => key,
                                      :domain => domain,
                                      :expire_after => 23.hours

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Sub::Application.config.session_store :active_record_store
