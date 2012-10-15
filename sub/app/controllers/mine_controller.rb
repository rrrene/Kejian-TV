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
    @seo[:title] = "稍后观看"    
  end
  def my_favorites
    @seo[:title] = "收藏"    
  end
  def my_liked_coursewares
    @seo[:title] = "顶过的课件"    
  end
private
  def mine_common_op
    @seo[:aux_title] = "#{Setting.ktv_subname}课件管理器"    
  end
end
