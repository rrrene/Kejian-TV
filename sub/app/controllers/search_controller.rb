# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def index
    @seo[:title] = '课件搜索'
    if params[:q].present?
      redirect_to "/search/#{params[:q]}"
      return false
    end
  end
  def lucky
    @pages = Page.psvr_search(@page,@per_page,params)
    redirect_to "/coursewares/#{@pages.first.courseware_id}"
    return false
  end
  def show
    search_common_op
  end
  def show_contents
    search_common_op
    @pages = Page.psvr_search(@page,@per_page,params)
  end
  def show_playlists
    search_common_op
  end
  def show_courses
    search_common_op
  end
  def show_teachers
    search_common_op
  end
  def show_users
    search_common_op
  end
private
  def search_common_op
    @seo[:title] = params[:q]
    @page = params[:page].to_i
    unless @page > 0
      @page = 1
      params[:page] = @page.to_s
    end
    params[:per_page] ||= cookies[:welcome_per_page]
    @per_page = params[:per_page].to_i
    unless @per_page > 0
      @per_page = 15 
      params[:per_page] = @per_page.to_s
    end
    cookies[:welcome_per_page] = @per_page.to_s
    params[:q]=params[:q].xi
  end
end

