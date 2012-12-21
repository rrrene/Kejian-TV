# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

if $psvr_really_production
  tbname = "sessions"
elsif $psvr_really_development
  tbname = "sessions_dev"
else
  tbname = "sessions_staging"
end
Sub::Application.config.session_store :active_record_store
ActiveRecord::SessionStore::Session.table_name = tbname
