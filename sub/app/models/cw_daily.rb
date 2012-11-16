# -*- encoding : utf-8 -*-
class CwDaily
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel

  field :cw_id
  # field :by_title               # Courseware直接  Comment间接
  field :acted_comment_ids,     :type=>Array, :default => []    ## [comment_id,action_type]

  field :user_ids,              :type=>Array, :default => []
  field :guests_count,          :type => Integer, :default => 0
  field :events_count,          :type => Integer, :default => 0
  
  field :cw_addedto_count,      :type => Integer, :default => 0
  field :cw_ding_count,         :type => Integer, :default => 0
  field :cw_cai_count,          :type => Integer, :default => 0
  field :cw_flag_count,         :type => Integer, :default => 0
  field :cw_pageview_count,     :type => Integer, :default => 0
  field :cw_comment_count,      :type => Integer, :default => 0
  field :cw_shared_by_email,    :type => Integer, :default => 0
  field :cw_download_count,     :type => Integer, :default => 0
  
  field :cw_in_search_count,    :type => Integer, :default => 0
  field :cw_in_recommend_count, :type => Integer, :default => 0
  field :cw_out_search_count,   :type => Integer, :default => 0
  field :cw_out_shared_count,   :type => Integer, :default => 0
  field :cw_view_by_embed_count,:type => Integer, :default => 0
  field :cw_out_unknown_count,  :type => Integer, :default => 0
  
  field :comment_ding_count,    :type => Integer, :default => 0
  field :comment_cai_count,     :type => Integer, :default => 0
  field :comment_remove_count,  :type => Integer, :default => 0
  field :comment_flag_count,    :type => Integer, :default => 0
  field :comment_comment_count, :type => Integer, :default => 0
  field :comment_parent_count,  :type => Integer, :default => 0
  
  field :dedicgotd_ips,         :type=>Array, :default => []  
  
  field :cw_in_search_referrer, :type => Array, :default => []          ### [e.referer,e.created_at,e.request_url]
  field :cw_in_recommend_referer,:type => Array, :default => []
  field :cw_out_search_referrer,:type => Array, :default => []         ##在CwEvent::ES_NAME<100&>=0的搜素引擎
  field :cw_out_shared_link,    :type => Array, :default => []         ##在CwEvent::ES_NAME>=100的分享网站来的
  field :cw_out_view_by_embeded,:type => Array, :default => []         ##
  field :cw_out_unknown_referer,:type => Array, :default => []         ##不在CwEvent::ES_NAME>=0里的外部来源
  field :cw_pageview_referer,   :type => Array, :default => []         ##站内页面切换
  
  field :is_mobiles,            :type => Array, :default => []         ##[created_at]
  
  field :failed_actions,        :type => Array, :default => []          ##[failed_action_type,created_at,title,id,request_url]
  field :date,                  :type =>Integer, :default => 1.day.ago.beginning_of_day().to_i
  def get_view_count
      return self.cw_pageview_count+self.cw_in_search_count+self.cw_in_recommend_count+self.cw_out_search_count+self.cw_out_shared_count+self.cw_view_by_embed_count+self.cw_out_unknown_count
  end
  def self.calculator
    # ytd = yesterday
    ytd = 1.day.ago.beginning_of_day().to_i
    ytdEvent = CwEvent.where(:date=> ytd)
    ytdEvent.each do |e|
        if e.title == 'Courseware'
            if e.title_id.nil?
                cw = CwDaily.find_or_create_by(:date => ytd,:cw_id => 'Application')
            else
                cw = CwDaily.find_or_create_by(:date => ytd,:cw_id => e.title_id)
            end
        elsif e.title == 'Comment'
            c = Comment.find(e.title_id)
            cw = CwDaily.find_or_create_by(:date => ytd,:cw_id => c.commentable_id)
            cw.update_attribute(:acted_comment_ids,cw.acted_comment_ids << [c.id,e.action])
            #TODO
        end
        if cw.nil?
            binding.pry
            next
        end
        
        ##events_count
        cw.inc(:events_count,1)
        ## user
        if !e.is_guest
            cw.update_attribute(:user_ids,cw.user_ids << e.user_id)
        else
            cw.inc(:guests_count,1)
        end
        ## ip
        if !cw.dedicgotd_ips.include?(e.ip)
            cw.update_attribute(:dedicgotd_ips,cw.dedicgotd_ips << e.ip)
        end
        
        if e.is_mobile
            cw.update_attribute(:is_mobiles,cw.is_mobiles << e.created_at)
        end
        
        ## event count
        case e.event_type
        when CwEvent::EVENT_LIST['普通操作']
            case e.action
               when CwEvent::ACTION_LIST['PageView']
                   cw.inc(:cw_pageview_count, 1)
               when CwEvent::ACTION_LIST['评论课件']
                   cw.inc(:cw_comment_count, 1)                    
               when CwEvent::ACTION_LIST['举报课件']
                   cw.inc(:cw_flag_count, 1)
               when CwEvent::ACTION_LIST['课件顶']
                   cw.inc(:cw_ding_count, 1)
               when CwEvent::ACTION_LIST['课件踩']
                   cw.inc(:cw_cai_count,1)
               when CwEvent::ACTION_LIST['添加收藏']
                   cw.inc(:cw_addedto_count, 1)
               when CwEvent::ACTION_LIST['下载']
                   cw.inc(:cw_download_count,1)
               when CwEvent::ACTION_LIST['评论顶']
                   cw.inc(:comment_ding_count,1)
               when CwEvent::ACTION_LIST['评论踩']
                   cw.inc(:comment_cai_count, 1)
               when CwEvent::ACTION_LIST['评论评论']
                   cw.inc(:comment_comment_count,1)
               when CwEvent::ACTION_LIST['评论举报']
                   cw.inc(:comment_flag_count,1)
               when CwEvent::ACTION_LIST['评论删除']
                   cw.inc(:comment_remove_count, 1)
               when CwEvent::ACTION_LIST['邮件分享']
                   cw.inc(:cw_shared_by_email, 1)
               when CwEvent::ACTION_LIST['查看父评论']
                   cw.inc(:comment_parent_count,1)
               when CwEvent::ACTION_LIST['NOT ACTION']
                #raise
#                cw.inc(:cw_pageview_count, 1)
            end
            
            if !e.succuss
                cw.update_attribute(:failed_actions,cw.failed_actions<<[e.action,e.created_at,e.title,e.title_id,e.request_url])
            end
        when CwEvent::EVENT_LIST['流量来源']
            cw.inc(:cw_out_unknown_count, 1)
            cw.update_attribute(:cw_out_unknown_referer,cw.cw_out_unknown_referer << [e.referer,e.created_at,e.request_url,e.keyword,e.source])
        when CwEvent::EVENT_LIST['站内搜索']
            cw.inc(:cw_in_search_count, 1)
            cw.update_attribute(:cw_in_search_referrer,cw.cw_in_search_referrer << [e.referer,e.created_at,e.request_url,e.keyword])
        when CwEvent::EVENT_LIST['站内推荐']
            cw.inc(:cw_in_recommend_count, 1)
            cw.update_attribute(:cw_in_recommend_referer,cw.cw_in_recommend_referer << [e.referer,e.created_at,e.request_url])
        when CwEvent::EVENT_LIST['站外搜索']
            cw.inc(:cw_out_search_count, 1)
            cw.update_attribute(:cw_out_search_referrer,cw.cw_out_search_referrer << [e.referer,e.created_at,e.request_url,e.keyword,e.source])
        when CwEvent::EVENT_LIST['站外分享']
            cw.inc(:cw_out_shared_count, 1)
            cw.update_attribute(:cw_out_shared_link,cw.cw_out_shared_link << [e.referer,e.created_at,e.request_url,e.source])
        when CwEvent::EVENT_LIST['PageView']
            cw.inc(:cw_pageview_count, 1)
            cw.update_attribute(:cw_pageview_referer,cw.cw_pageview_referer << [e.referer,e.created_at,e.request_url])
#        when CwEvent::EVENT_LIST['内嵌观看']
           # cw.inc(:cw_view_by_embed_count, 1)
#            cw.update_attribute(:cw_out_view_by_embeded,cw.cw_out_view_by_embeded << [e.referer,e.created_at,e.request_url])
        end
    end
  end
  
  
  def self.last_month_milestone_check
    dailys = CwDaily.where(:date.gt => 1.month.ago.beginning_of_month().to_i).asc('date')
    self.milestone_check(dailys)
  end
  def self.half_month_milestone_check
    dailys = CwDaily.where(:date.gt => Time.now.beginning_of_month().to_i).asc('date')
    self.milestone_check(dailys)    
  end
  def self.milestone_check(dailys)
    dailys.each do |day|
        if day.cw_id == 'App'
            next
        end
        cw = Courseware.find(day.cw_id)
=begin
        MILESTONE_TYPE = {
             0 => '来自 课件TV 搜索的首次推荐',
             1 => '来自相关课件的首次推荐',
             2 => '来自 外部 搜索的首次推荐',
             3 => '来自 外部 的首次分享',
             4 => '第一通过嵌入方式观看'
             5 => '第一次通过移动设备观看',
             6 => '第一次得到订阅者模块的推荐'
        }
=end
        if !day.cw_in_search_referrer.blank? and !cw.milestone.has_key?('0')#Courseware::MILESTONE_TYPE[0]
            cw.milestone['0'] = [day.cw_in_search_referrer[0],day.cw_in_search_referrer.count] #Courseware::MILESTONE_TYPE[0]
        elsif !day.cw_in_search_referrer.blank? and cw.milestone.has_key?('0')
            cw.milestone['0'][1] += day.cw_in_search_referrer.count
        end
        if !day.cw_in_recommend_referer.blank? and !cw.milestone.has_key?('1')
            cw.milestone['1'] = [day.cw_in_recommend_referer[0],day.cw_in_recommend_referer.count]
        elsif !day.cw_in_recommend_referer.blank? and cw.milestone.has_key?('1')
            cw.milestone['1'][1] += day.cw_in_recommend_referer.count
        end
        
        if !day.cw_out_search_referrer.blank? and !cw.milestone.has_key?('2')
            cw.milestone['2'] = [day.cw_out_search_referrer[0],day.cw_out_search_referrer.count]
        elsif !day.cw_out_search_referrer.blank? and cw.milestone.has_key?('2')
            cw.milestone['2'][1] += day.cw_out_search_referrer.count
        end
        if !day.cw_out_shared_link.blank? and !cw.milestone.has_key?('3')
            cw.milestone['3'] = [day.cw_out_shared_link[0],day.cw_out_shared_link.count]
        elsif !day.cw_out_shared_link.blank? and cw.milestone.has_key?('3')
            cw.milestone['3'][1] += day.cw_out_shared_link.count
        end
        
        if !day.cw_out_view_by_embeded.blank? and !cw.milestone.has_key?('4')
            cw.milestone['4'] = [day.cw_out_view_by_embeded[0],day.cw_out_view_by_embeded.count]
        elsif !day.cw_out_view_by_embeded.blank? and cw.milestone.has_key?('4')
            cw.milestone['4'][1] += day.cw_out_view_by_embeded.count
        end
        
        if !day.is_mobiles.blank? and !cw.milestone.has_key?('5')
            cw.milestone['5'] = [day.is_mobiles,day.is_mobiles.count]
        elsif !day.is_mobiles.blank? and cw.milestone.has_key?('5')
            cw.milestone['5'][1] += is_mobiles.count
        end
        cw.save(:validate => false)
    end
  end

  ## Cleaner
  def self.today_cleaner
    CwEvent.where(:date=> Time.now.beginning_of_day().to_i).destroy_all
  end
  def self.yesterday_cleaner
    CwEvent.where(:date=> 1.day.ago.beginning_of_day().to_i).destroy_all
  end
  def self.cleaner
     CwEvent.destroy_all
  end
  
end
