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
    search_common_op
    @pages = Page.psvr_search(@page,@per_page,params)
    redirect_to "/coursewares/#{@pages.first.courseware_id}"
    return false
  end
  def show
    search_common_op
    @coursewares = Courseware.psvr_search(@page,@per_page,params)
    @quans=@coursewares
    @quan='个'
    @thing='课件'
    @mode=:kejian
    respond_to do |format|
      format.html
      format.json{
        render json:{
          term:@user_provided_term,
          content:render_to_string(:file=>'search/_show.html.erb',:layout=>nil, :formats=>[:html]),
          main:render_to_string(:file=>'search/_search_show_common_main.html.erb',:layout=>nil, :formats=>[:html])
        }
      }
    end
  end
  def show_contents
    search_common_op
    @pages = Page.psvr_search(@page,@per_page,params)
    @quans=@pages
    @quan='页'
    @thing='课件内容'
    @mode=:kejianneirong
    respond_to do |format|
      format.html
      format.json{
        render json:{
          term:@user_provided_term,
          content:render_to_string(:file=>'search/_show_contents.html.erb',:layout=>nil, :formats=>[:html]),
          main:render_to_string(:file=>'search/_search_show_common_main.html.erb',:layout=>nil, :formats=>[:html])
        }
      }
    end
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
    @user_provided_term=params[:q]
    @using_ajax = request.path.split('/')[1]=='ajax'
    @seo[:title] = params[:q]
    @page = params[:page].to_i
    unless @page > 0
      @page = 1
      params[:page] = @page.to_s
    end
    params[:per_page] ||= cookies[:search_per_page]
    @per_page = params[:per_page].to_i
    unless @per_page > 0
      @per_page = 10 
      params[:per_page] = @per_page.to_s
    end
    cookies[:search_per_page] = @per_page.to_s
    params[:q]=params[:q].xi
  end
end

