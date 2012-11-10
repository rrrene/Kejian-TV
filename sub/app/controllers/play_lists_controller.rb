# -*- encoding : utf-8 -*-
class PlayListsController < ApplicationController
  prepend_before_filter proc{@psvr_payloads||=[];@psvr_payloads << 'whosonlinestatus'},:only=>[:index]
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
    @seo[:title]='课件锦囊'
    @play_lists = PlayList.no_privacy.destroyable.normal
    @play_lists = @play_lists.paginate(:page => params[:page], :per_page => @per_page)
  end
  
  def new
    @play_list = PlayList.new
  end

  def edit
    @play_list = PlayList.find(params[:id])
    if current_user.nil? or current_user.id != @play_list.user_id 
        flash[:notice] = "该课件锦囊为私有，您无权修改。"
        redirect_to '/mine/view_all_playlists'
        return false
    end
  end
  def show
    @playlist = PlayList.find(params[:id])
    if @playlist.privacy !=0 and !current_user.nil? and current_user.id != @playlist.user_id
        flash[:notice] = "该课件锦囊为私有，您无权查看。"
        redirect_to '/mine/view_all_playlists'
        return false
    end
    # @coursewares = Courseware.eager_load(@playlist.content)
    @playlist.inc(:views_count,1)
    @user = User.find(@playlist.user_id)
    @seo[:title] = "课件锦囊"    
  end
  def handler
    hash = Digest::MD5.hexdigest(params[:id]+'.liber.'+Digest::MD5.hexdigest(params[:form_hash]))
    if hash != params[:encrypted_playlist_id]
      flash[:error] = "来路不明。"
      redirect_to '/'
      return false
    end
    if current_user.nil? 
      flash[:error] = "请首先登录。"
      redirect_to '/'
      return false
    end
    if params[:action_delete] == '1'
      destroy
      return true
    end
    msg = ''
    if params[:title].blank?
      msg += " 课件锦囊标题是必填项。"
    end
    if !params[:playlist_thumbnail_video_id].blank? and !Moped::BSON::ObjectId.legal?(params[:playlist_thumbnail_video_id])
      msg += ' 请不要搞破坏：）要乖哦！'
    end
    if !params[:playlist_kejian_id].blank?
      params[:playlist_kejian_id].each do |id|
        if !Moped::BSON::ObjectId.legal?(id)
          if !msg.include?(' 请不要搞破坏：）')
            msg += ' 请不要搞破坏：）要乖哦！'
          end
          break
        end
      end
    end
    pl = PlayList.find(params[:id])
    pl.title = params[:title]
    pl.content = params[:playlist_kejian_id]
    pl.annotation = params[:playlist_video_annotation]
    if !params[:playlist_kejian_deleted].blank?
      params[:playlist_kejian_deleted].each_with_index do |tf,index|
        if tf != '0'
          pl.content.delete_at(index)
          pl.annotation.delete_at(index)
        end
      end
    end
    pl.user_id = current_user.id
    pl.playlist_thumbnail_kejian_id = params[:playlist_thumbnail_video_id].to_s
    pl.desc = params[:description]
    
    pl.privacy = params[:is_private].to_i == 1 ? 1 : 0
    pl.playlist_allow_embedding = params[:allow_embedding].to_i == 1 ? true : false
    pl.playlist_allow_ratings = params[:allow_ratings].to_i == 1 ? true :false
    pl.playlist_enable_grid_view = params[:enable_grid_view].to_i == 1 ? true :false
    
    if msg =='' and pl.save
      flash[:notice] = "课件锦囊#{pl.title}修改成功。"
      redirect_to "/play_lists/#{pl.id}"
    else
      flash[:notice] = "课件锦囊#{pl.title}修改失败。" + msg
      redirect_to edit_play_list_path(pl.id)
    end
  end
  def destroy
    pl = PlayList.find(params[:id])
    if !current_user.nil? and current_user.id == pl.user_id
      pl.deleted = 1
      pl.save(:validation=>false)
      flash[:notice] = "课件锦囊#{pl.title}成功删除。"
      redirect_to '/mine/view_all_playlists'
    else
      flash[:notice] = "课件锦囊#{pl.title}删除失败。"
      redirect_back_or_default '/'
    end
  end
  def create
    
  end
  
  def update


  end
end
