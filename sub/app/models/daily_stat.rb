# -*- encoding : utf-8 -*-
class DailyStat
  include Mongoid::Document
    
  field :ask_user_count
  field :answer_user_count
  field :login_user_count
  field :created_at
  
  # index :created_at
  
  def self.insert_daily_stat(time)
    today_start=time.at_beginning_of_day-1.days
    today_end=time.at_beginning_of_day
    from_now_30=time.at_beginning_of_day-30.days
    #每日的前30天的提问用户总数
    ask_user_count=Ask.nondeleted.where(:created_at.gte=>from_now_30,:created_at.lte=>today_end).map{|x|x.user_id}.uniq.count
    #每日的前30天的解答用户总数
    answer_user_count=Answer.nondeleted.where(:created_at.gte=>from_now_30,:created_at.lte=>today_end).map{|x|x.user_id}.uniq.count
    #每天登录的用户数
    login_user_count=User.nondeleted.where(:last_login_at.gte=>today_start,:last_login_at.lte=>today_end).count
    DailyStat.create(:ask_user_count=>ask_user_count,:answer_user_count=>answer_user_count,:login_user_count=>login_user_count,:created_at=>today_start.strftime("%Y-%m-%d"))
  end
  
end
