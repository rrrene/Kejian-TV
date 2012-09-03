# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    @seo[:title] = '首页'


    @stat = PreCommonStat.order
    ###session
    @session_all = PreCommonSession.all
    @session_count = @session_all.count
    @onlinelistx=  @session_all.map {|u| u.username}
    @onlinetime  =  @session_all.map {|u| u.lastactivity}

    @onlinelist =  @onlinelistx.compact
    @onlinelist_count = @onlinelist.count
    @guest_count = @session_count - @onlinelist_count
    
    
    
    @courses = PreForumForum.order('threads desc').limit(10)
    @coursewares = PreForumThread.order('views desc').limit(10)
    @coursewares1 = PreForumThread.where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    @cwyesterday = PreForumThread.where('dateline>=? and dateline <?',Date.yesterday.at_beginning_of_day.to_i,Date.today.at_beginning_of_day.to_i).count
    @cw = PreForumThread.count
    @users = PreCommonMember.count
    @newuser =  PreCommonMember.order('regdate').last
    if @coursewares1.count > 0
      @coursewares2 = PreForumThread.where('dateline<?',@coursewares1[-1].dateline).order('dateline desc').first
    else
      @coursewares2 = PreForumThread.order('dateline desc').first
    end
    if @coursewares2
      @coursewares2 = PreForumThread.where('dateline<=? and dateline>=?',Time.at(@coursewares2.dateline).to_i,Time.at(@coursewares2.dateline).at_beginning_of_day.to_i).order('dateline desc')
      @coursewares3 = PreForumThread.where('dateline<?',@coursewares2[-1].dateline).order('dateline desc').first
      if @coursewares3
        @coursewares3 = PreForumThread.where('dateline<=? and dateline>=?',Time.at(@coursewares3.dateline).to_i,Time.at(@coursewares3.dateline).at_beginning_of_day.to_i).order('dateline desc')
      end
    end
  end
end
