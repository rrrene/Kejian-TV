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
    search_common_over
  end
  def show_contents
    search_common_op
    @pages = Page.psvr_search(@page,@per_page,params)
    @quans=@pages
    @quan='页'
    @thing='课件内容'
    @mode=:kejianneirong
    search_common_over
  end
  def show_playlists
    search_common_op
    @play_lists = PlayList.destroyable.psvr_search(@page,@per_page,params)
    @quans=@play_lists
    @quan='包'
    @thing='课件锦囊'
    @mode=:bofangliebiao
    search_common_over
  end
  def show_courses
    search_common_op
  end
  def show_teachers
    search_common_op
    q=params[:q]
    r0 = Time.now
    @teachers = Redis::Search.query("Teacher",q,:limit=>500,:sort_field=>'coursewares_count')
    @teachers += Redis::Search.complete("Teacher",q,:limit=>500,:sort_field=>'coursewares_count')
    @teachers = @teachers.psvr_uniq
    @teachers = @teachers.paginate(:page => @page, :per_page => @per_page)
    @time_elapsed = ((Time.now - r0) * 1000.0).to_i
    @quans=@teachers
    @quan='位'
    @thing='老师'
    @mode=:laoshi
    search_common_over
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
  def search_common_over
    if !current_user.nil? and current_user.mark_search_keyword
      SearchHistory.add_search_keyword(current_user,params[:q],request.ip,params[:action])      
    end
    respond_to do |format|
      format.html{
        render 'show'
      }
      format.json{
        render json:{
          term:@user_provided_term,
          content:render_to_string(:file=>"search/_#{params[:action]}.html.erb",:layout=>nil, :formats=>[:html]),
          main:render_to_string(:file=>'search/_search_show_common_main.html.erb',:layout=>nil, :formats=>[:html])
        }
      }
    end
  end
end

