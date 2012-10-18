# -*- encoding : utf-8 -*-
class PlayListsController < ApplicationController
  def index
    common_op!
    @seo[:title]='课件锦囊'
    @play_lists = PlayList.no_privacy.destroyable#.normal
    @play_lists = @play_lists.paginate(:page => params[:page], :per_page => @per_page)
  end
  
  def new
    @play_list = PlayList.new
  end

  def edit
    @play_list = PlayList.find(params[:id])
  end
  
  def show
    @play_list = PlayList.find(params[:id])
    @seo[:title] = "课件锦囊"    
  end

  def create
    
  end
  
  def update
    
  end
end
