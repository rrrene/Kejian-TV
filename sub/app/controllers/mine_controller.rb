# -*- encoding : utf-8 -*-

class MineController < ApplicationController
  before_filter :require_user
  def index
    redirect_to '/mine/my_coursewares'
    return false
  end
  def dashboard
    mine_common_op
    @seo[:title] = "信息中心"
  end
  def my_coursewares
    @seo[:title] = "上传的课件"    
  end
  def view_all_playlists
    @seo[:title] = "课件锦囊"    
    @uplist = PlayList.nondeleted.where(:user_id => current_user.id,:undestroyable=>false).desc('created_at')
  end
  def my_coursewares_copyright
    @seo[:title] = "版权声明"    
  end
  def my_history
    @seo[:title] = "历史记录"    
  end
  def my_search_history
    @seo[:title] = "搜索记录"    
  end
  def my_watch_later_coursewares
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @list = PlayList.locate(current_user.id,'稍后阅读')
    @coursewares_ids = @list.content
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "稍后阅读"
  end
  def my_favorites
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @list = PlayList.locate(current_user.id,'收藏')
    @coursewares_ids = @list.content
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "收藏"    
  end
  def my_liked_coursewares
    if current_user.nil?
      redirect_to '/'
      return false
    end
    @coursewares_ids = current_user.thanked_courseware_ids
    @thanked_playlist_ids = current_user.thanked_play_list_ids
    @coursewares = Courseware.eager_load(@coursewares_ids)
    @seo[:title] = "顶过的课件"    
  end
  def my_liked_lists
    @coursewares_ids = current_user.thanked_courseware_ids
    @thanked_playlist_ids = current_user.thanked_play_list_ids
    @uplist = PlayList.eager_load(@thanked_playlist_ids)
    @seo[:title] = "顶过的课件锦囊"
  end
private
  def mine_common_op
    @seo[:aux_title] = "#{Setting.ktv_subname}课件管理器"    
  end
end
