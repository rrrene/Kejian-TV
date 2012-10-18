# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    will_redirect = (!current_user and params[:psvr_force].blank?)
    if !will_redirect
      common_op!
      if current_user
        @coursewares=Courseware.normal_father.any_of(
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
    @coursewares = Courseware.normal_father.no_privacy
    @coursewares = Courseware.additional_conditions(@coursewares,params)
    @coursewares = @coursewares.paginate(:page => params[:page], :per_page => @per_page)
    render 'index'
  end
  def featured
    @seo[:title] = '资源广场'
    common_op!
    @coursewares=Courseware.normal.desc('downloads_count').paginate(:page => params[:page], :per_page => @per_page)
    render 'index'
  end
  def hot
    @seo[:title] = '最热课件'
    common_op!
    @coursewares=Courseware.normal.desc('views_count').paginate(:page => params[:page], :per_page => @per_page)
    render 'index'    
  end
  def inactive_sign_up
    render "inactive_sign_up#{@subsite}",layout:'application_for_devise'
  end
  def shuffle
    cw = nil
    i = 0
    while !(cw and 0==cw.status and !cw.deleted?)
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
      format.rss{@coursewares = Courseware.normal_father.desc('created_at').limit(10);render :layout=>false}
    end
  end
private
end

