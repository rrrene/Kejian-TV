# -*- encoding : utf-8 -*-

class MineController < ApplicationController
  before_filter :require_user
  before_filter :page_require
  def page_require
    params[:page] ||= '1'
    params[:per_page] ||= cookies[:welcome_per_page]
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
    cookies[:welcome_per_page] = @per_page
  end
  def index
    redirect_to '/mine/my_coursewares'
    return false
  end
  def dashboard
    mine_common_op
    @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id).desc('created_at').limit(4)
    @readlater = PlayList.where(user_id:current_user.id,undestroyable:true,title:'稍后阅读').first
    @seo[:title] = "信息中心"
  end
  def my_coursewares
    if current_user.nil?
      flash[:notice]='您尚未登录'
      redirect_to '/'
      return false
    end
    if params[:privacy].blank? and params[:q].blank?
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id).desc('created_at')
    elsif params[:privacy] == 'public' or params[:q] == 'is:public'
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id,privacy:0).desc('created_at')
    elsif params[:privacy] == 'unlisted' or params[:q] == 'is:unlisted'
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id,privacy:1).desc('created_at')
    elsif params[:privacy] == 'private' or params[:q] == 'is:private'
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id,privacy:2).desc('created_at')
    elsif params[:privacy].blank? and !params[:q].blank?
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id,title:/#{params[:q]}/).desc('created_at')
    end
    if !@coursewares.nil?
      @coursewares = @coursewares.paginate(:page => params[:page], :per_page => @per_page)
    end
    @seo[:title] = "上传的课件" 
  end
  def view_all_playlists
    @seo[:title] = "课件锦囊"    
    @uplist = PlayList.nondeleted.where(:user_id => current_user.id,:undestroyable=>false).desc('created_at').paginate(:page => params[:page], :per_page => @per_page)
  end
  def my_coursewares_copyright
    @seo[:title] = "版权声明"    
  end
  def my_history
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @list = PlayList.locate(current_user.id,'历史记录')
    @coursewares_ids = @list.content.paginate(:page => params[:page], :per_page => @per_page)
    @history_mark = @list.history_time_mark.paginate(:page => params[:page], :per_page => @per_page)
    @coursewares = Courseware.eager_load(@coursewares_ids)    
    @seo[:title] = "历史记录"    
  end
  def my_search_history
    @seo[:title] = "搜索记录"    
    @list = SearchHistory.locate_search_history(current_user.id).paginate(:page => params[:page], :per_page => @per_page)
  end
  def my_watch_later_coursewares
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @list = PlayList.locate(current_user.id,'稍后阅读')
    @coursewares_ids = @list.content.paginate(:page => params[:page], :per_page => @per_page)
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "稍后阅读"
  end
  def my_favorites
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @list = PlayList.locate(current_user.id,'收藏')
    @coursewares_ids = @list.content.paginate(:page => params[:page], :per_page => @per_page)
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "收藏"    
  end
  def my_liked_coursewares
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @coursewares_ids = current_user.thanked_courseware_ids.paginate(:page => params[:page], :per_page => @per_page)
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "顶过的课件"    
  end
  def my_liked_lists
    @thanked_playlist_ids = current_user.thanked_play_list_ids.paginate(:page => params[:page], :per_page => @per_page)
    @uplist = PlayList.eager_load(@thanked_playlist_ids)
    @seo[:title] = "顶过的课件锦囊"
  end
private
  def mine_common_op
    @seo[:aux_title] = "#{Setting.ktv_subname}课件管理器"    
  end
end
