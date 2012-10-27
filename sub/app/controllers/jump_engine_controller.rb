# -*- encoding : utf-8 -*-
class JumpEngineController < ApplicationController
  layout:false
  def url    
    headers["Status"] = "301 Moved Permanently"
    params[:url] ||= '/'
    params[:t] || = 's' #t =>type s=>search
    case params[:t]
    when 's'
        add_to_search_history
    end
    redirect_to params[:url]
  end
  
  def add_to_search_history
    
  end
  
end
