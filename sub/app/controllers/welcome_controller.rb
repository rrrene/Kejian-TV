# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  prepend_before_filter proc{@psvr_payloads||=[];@psvr_payloads << 'whosonlinestatus'},:only=>[:latest]
  def index
    # todo: 新鲜事
    redirect_to '/welcome/latest'
    return false
    will_redirect = (!current_user and params[:psvr_force].blank?)
    if !will_redirect
      common_op!
      if current_user
        @coursewares=Courseware.nondeleted.normal.is_father.any_of(
          {:user_id.in => current_user.following_ids},
          {:uploader_id.in => current_user.following_ids},
          {:course_fid.in => current_user.followed_course_fids}
        )
        .excludes(:uploader_id => current_user.id).desc('created_at')
        .paginate(:page => params[:page], :per_page => @per_page)
      else 
        @coursewares = []
      end
      will_redirect ||= (0==@coursewares.count and params[:psvr_force].blank?)
    end
    if will_redirect
      redirect_to '/welcome/latest'
      return
    else
      @dz_navi_extras = []
      @seo[:title] = '我的首页'
      render
    end
  end
  def latest
    @seo[:title] = '全部课件'
    common_op!
    @coursewares = Courseware.nondeleted.normal.is_father.no_privacy
    @coursewares = Courseware.additional_conditions(@coursewares,params)
    @coursewares = @coursewares.paginate(:page => params[:page], :per_page => @per_page)
    render 'index'
  end
  def featured
    @seo[:title] = '资源广场'
    common_op!
    @coursewares=Courseware.nondeleted.normal.is_father.desc('downloads_count').paginate(:page => params[:page], :per_page => @per_page)
    render 'index'
  end
  def hot
    @seo[:title] = '最热课件'
    common_op!
    @coursewares=Courseware.nondeleted.normal.is_father.desc('views_count').paginate(:page => params[:page], :per_page => @per_page)
    render 'index'    
  end
  def inactive_sign_up
    @seo[:title]='请查收确认邮件'
    render "inactive_sign_up",layout:'application_for_devise'
  end
  def shuffle
    cw = nil
    i = 0
    while !(cw and 0==cw.status and !cw.soft_deleted?)
      cw = Courseware.skip(rand(Courseware.count)).first
      i += 1
      if i>10
        redirect_to '/'
        return
      end
    end
    redirect_to cw
  end
  def feeds
    respond_to do |format|
      format.html{redirect_to '/welcome/feeds.rss' and return}
      format.rss{@coursewares = Courseware.nondeleted.normal.is_father.desc('created_at').limit(10);render :layout=>false}
    end
  end

  def iphone
    
  end
  def assets
    ret = Sub::Application.config.action_controller.asset_host.to_s+ActionController::Base.helpers.asset_path(params[:path])
    redirect_to ret, :status => :moved_permanently
  end
private
  def common_op!
    params[:page] ||= '1'
    params[:per_page] ||= cookies[:welcome_per_page]
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
    cookies[:welcome_per_page] = @per_page
  end
end

