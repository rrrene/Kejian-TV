# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    @seo[:title] = '首页'
    @stat = PreCommonStat.order
    ###session
    @showoldetails = params[:showoldetails]=='no' ? false : true

    ###online list begin
    @session_all = PreCommonSession.all
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
    @online_display = Hash[@online_groupid.zip(@onlinelist_username.zip(@onlinelist_uid).zip(@online_lastactivitytime.zip(@online_invisible)))]

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

    @on_display = Hash.new
    @pic.each do |keys,values|
      @online_display.each do |on_keys,on_values|
        if keys == on_keys
          @on_display[values[0]] = on_values + [values[1]]
        end
      end
    end
    @on_display = Hash[@on_display.sort_by {|key,value| key}]
    ##@on_display => {1=>[["libo-liu", 35], [1346730846, false], ["管理员", "online_admin.gif"]], 3=>[["llb0536", 61], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@onlinelist => {display_order  => [[username,uid],[time,invisible?],[group_title,group_icon]]}
    ###onlinelist end
    
    ###onlinerecord max begin
    @onlinerecord = PreCommonSetting. where(:skey => 'onlinerecord').first.svalue.split.compact
    ###onlinerecord max end
    @coursewares1 = PreForumThread.nondeleted.where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    @cwyesterday = PreForumThread.nondeleted.where('dateline>=? and dateline <?',Date.yesterday.at_beginning_of_day.to_i,Date.today.at_beginning_of_day.to_i).count
    @cw = PreForumThread.nondeleted.count
    @users = PreCommonMember.count
    @newuser =  PreCommonMember.order('regdate').last

    @departments = Department.asc('created_at')
    # 
    # 
    # 
    @courses = PreForumForum.order('threads desc').limit(10)
    @coursewares = PreForumThread.nondeleted.order('views desc').limit(10)
    @coursewares1 = PreForumThread.nondeleted.where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    
    if @coursewares1.count > 0
      @coursewares2 = PreForumThread.nondeleted.where('dateline<?',@coursewares1[-1].dateline).order('dateline desc').first
    else
      @coursewares2 = PreForumThread.nondeleted.order('dateline desc').first
    end
    if @coursewares2
      @coursewares2 = PreForumThread.nondeleted.where('dateline<=? and dateline>=?',Time.at(@coursewares2.dateline).to_i,Time.at(@coursewares2.dateline).at_beginning_of_day.to_i).order('dateline desc')
      @coursewares3 = PreForumThread.nondeleted.where('dateline<?',@coursewares2[-1].dateline).order('dateline desc').first
      if @coursewares3
        @coursewares3 = PreForumThread.nondeleted.where('dateline<=? and dateline>=?',Time.at(@coursewares3.dateline).to_i,Time.at(@coursewares3.dateline).at_beginning_of_day.to_i).order('dateline desc')
      end
    end
  end

end
