# -*- encoding : utf-8 -*-
class MobileController < ApplicationController
  layout 'application.mobile'
  
  def login
    @no_search_bar = true
  end
  
  def register
    @no_search_bar = true
  end
  
  def search
  end
  
  def notifications
    if current_user
      @notifies, @notifications = current_user.unread_notifies
    end
  end
  
  def noticepage
  end

end
