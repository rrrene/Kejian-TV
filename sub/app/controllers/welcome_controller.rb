# -*- encoding : utf-8 -*-
class WelcomeController < ApplicationController
  def index
    @seo[:title] = '首页'
    @courses = PreForumForum.order('threads desc').limit(10)
    @coursewares = PreForumThread.order('views desc').limit(10)
    @coursewares1 = PreForumThread.order('dateline desc').where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    if @coursewares1.count > 0
      @coursewares2 = PreForumThread.order('dateline desc').where('dateline<?',@coursewares1[-1].dateline).first
    else
      @coursewares2 = PreForumThread.order('dateline desc').first
    end
    if @coursewares2
      @coursewares2 = PreForumThread.order('dateline desc').where('dateline<=? and dateline>=?',Time.at(@coursewares2.dateline).to_i,Time.at(@coursewares2.dateline).at_beginning_of_day.to_i)
      @coursewares3 = PreForumThread.order('dateline desc').where('dateline<?',@coursewares2[-1].dateline).first
      if @coursewares3
        @coursewares3 = PreForumThread.order('dateline desc').where('dateline<=? and dateline>=?',Time.at(@coursewares3.dateline).to_i,Time.at(@coursewares3.dateline).at_beginning_of_day.to_i)
      end
    end
  end
  def favicon
    send_file "#{Rails.root}/simple/#{Setting.ktv_sub}_favicon.ico",disposition:'inline'
  end
end
