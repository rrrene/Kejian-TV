# -*- encoding : utf-8 -*-
class AccessesController < ApplicationController
  layout 'oauth'
  before_filter :find_accesses
  before_filter :find_access, except: "index"

  def index
  end

  def show
  end


  private 
  
    def find_accesses
      @accesses = OauthAccess.where(user_id: current_user.id)
    end

    def find_access
      @access = @accesses.find(params[:id])
      unless @access
        redirect_to root_path, alert: "Resource not found."
      end
    end

    # TODO: change this behavior with a simple redirect
    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end 

end
