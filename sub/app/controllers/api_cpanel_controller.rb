# -*- encoding : utf-8 -*-
class ApiCpanelController < ApplicationController
  layout 'oauth'
  before_filter :authenticate_user!
  def index
    
  end
protected
  def require_user
    if !current_user
      render 'require_user',:layout=>'oauth'
      return
    end
  end
end
