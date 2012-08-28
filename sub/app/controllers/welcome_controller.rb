# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    @seo[:title] = '首页'
  end
  def favicon
    send_file "#{Rails.root}/app/assets/images/cnu_foto/favicon.ico",disposition:'inline'
  end
end
