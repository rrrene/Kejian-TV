# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.


key = ($psvr_really_development ?  "_ktv_#{Setting.ktv_sub}_local_session" : "_ktv_#{Setting.ktv_sub}_session")
domain = Setting.ktv_subdomain

Sub::Application.config.session_store :cookie_store, 
                                      :key => key,
                                      :domain => domain,
                                      :expire_after => 23.hours

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Sub::Application.config.session_store :active_record_store
