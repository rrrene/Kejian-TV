# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    will_redirect = (!current_user and params[:psvr_force].blank?)
    if !will_redirect
      common_op!
      @coursewares=Courseware.normal.any_of(
        {:user_id.in => current_user.following_ids},
        {:uploader_id.in => current_user.following_ids},
        {:course_fid.in => current_user.followed_course_fids}
      )
      .excludes(:uploader_id => current_user.id).desc('created_at')
      .paginate(:page => params[:page], :per_page => @per_page)
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
    @seo[:title] = '最新上传'
    common_op!
    @coursewares=Courseware.normal_father
    @coursewares = @coursewares.where(:sort1=>params[:sort1]) if params[:sort1].present? and params[:sort1]!='all'
    if 'all'==params[:order] or params[:order].blank?
      @coursewares = @coursewares.desc('created_at')
    else
      @coursewares = @coursewares.desc('slides_count') if 'slides_count1'==params[:order]
      @coursewares = @coursewares.asc('slides_count') if 'slides_count0'==params[:order]
      @coursewares = @coursewares.desc('price') if 'price1'==params[:order]
      @coursewares = @coursewares.asc('price') if 'price0'==params[:order]
      @coursewares = @coursewares.desc('thanked_count') if 'thanked_count1'==params[:order]
      @coursewares = @coursewares.asc('thanked_count') if 'thanked_count0'==params[:order]
      @coursewares = @coursewares.where(:human_time.gt=>0).desc('human_time') if 'human_time1'==params[:order]
      @coursewares = @coursewares.where(:human_time.gt=>0).asc('human_time') if 'human_time0'==params[:order]
    end
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
    
  end
private
  def common_op!
    @dz_navi_extras = [
      ['我的首页','/?psvr_force=1']
    ]
    params[:page] ||= '1'
    params[:per_page] ||= cookies[:welcome_per_page]
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
    cookies[:welcome_per_page] = @per_page

    @stat = PreCommonStat.order
    ###session
    @showoldetails = params[:showoldetails]=='no' ? false : true

    ###online list begin
    @session_all = PreCommonSession.all(:limit => 500)
    @online_pic = PreForumOnlinelist.all

    @pic_list = @online_pic.map {|p| p.url}
    @pic_groupid = @online_pic.map {|p| p.groupid}
    @pic_order = @online_pic.map {|p| p.displayorder}
    @pic_title = @online_pic.map {|p| p.title}
    @pic = Hash[@pic_groupid.zip(@pic_order.zip(@pic_title.zip(@pic_list)))]
    @pic_sorted = Hash[@pic.sort_by {|key,value| value[0]}]
    ##@pic => {1       => [1, ["管理员", "online_admin.gif"]],...}
    ##@pic => {groupid  => [display_order,[title,icon]]}
    @onlinelist_uid = @session_all.map {|u| u.uid}
    @onlinelist_username=  @session_all.map {|u| u.username}
    @online_lastactivitytime  =  @session_all.map {|u| u.lastactivity}
    @online_invisible  = @session_all.map {|u| u.invisible}
    @online_groupid = @session_all.map {|u| u.groupid}
    @online_display = Hash[@onlinelist_uid.zip(@onlinelist_username.zip(@online_groupid).zip(@online_lastactivitytime.zip(@online_invisible)))]
    ##online_display => {1=>[["libo-liu", 35], [1346906335, false]],10=>[["gslipt", 62], [1346906466, false]]}
    ##online_display => { uid => [[username,group_id],[lastact,invisible]]}

    @session_count = @session_all.count
    @onlinelist =  @onlinelist_username.compact
    @online_invisible_count = @online_invisible.delete_if {|d| d==false}.count
    @onlinelist_count =  @onlinelist_username.delete_if {|d| d==''}.count

    @guest_count = @session_count - @onlinelist_count

    @online_display.each do |on_keys,on_values|
      if on_values[0][0].blank?
        @online_display.delete(on_keys)
      end
    end
    
    @lastone2display = @pic.values.max[0]
    @on_display = Hash.new
    @pic.each do |keys,values|
      @online_display.each do |on_keys,on_values|
        if @pic.keys.include?(on_values[0][1]) 
          if on_values[0][1] == keys
            @on_display[on_keys] = [values[0]] + on_values +[values[1]]
          end
        else
          @on_display[on_keys] = [@lastone2display] + on_values + [values[1]]
        end
      end
    end
    
    @on_display = Hash[@on_display.sort_by {|key,value| value[0]}]
    ##@on_display => {1=>[["libo-liu", 35], [1346730846, false], ["管理员", "online_admin.gif"]], 3=>[["llb0536", 61], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@on_display => {35=>[1,["libo-liu", 35], [1346730846, false], ["管理员", "online_admin.gif"]], 61=>[3,["llb0536", 61], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@on_display => {35=>[1, ["libo-liu", 1], [1346908864, false], ["管理员", "online_admin.gif"]],, 61=>[3,["llb0536", 4], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@onlinelist => {uid => [display_order,[username,group_id],[time,invisible?],[group_title,group_icon]]}
    ###onlinelist end
    
    ###onlinerecord max begin
    @onlinerecord = PreCommonSetting. where(:skey => 'onlinerecord').first.svalue.split.compact
    ###onlinerecord max end
    @coursewares1 = PreForumThread.nondeleted.where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    @cwyesterday = PreForumThread.nondeleted.where('dateline>=? and dateline <?',Date.yesterday.at_beginning_of_day.to_i,Date.today.at_beginning_of_day.to_i).count
    @cw = PreForumThread.nondeleted.count
    @users = PreCommonMember.count
    @newuser =  PreCommonMember.order('regdate').last
  end
end

