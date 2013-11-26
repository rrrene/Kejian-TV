# -*- encoding : utf-8 -*-
class SettingItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key
  field :value
  validate :key,:unique=>true
  
  #  "need_verification"              是否开启先审后发机制
  #  "need_verification_start_time"   先审后发机制每天几点开始
  #  "need_verification_end_time"     先审后发机制每天几点结束
 
  #  "hot_asks_created_at"            限制热门题为最近几天内发布的
  #  "hot_asks_answers_count"         限制热门题为解答数不少于几的
  #  "hot_asks_refresh_minute"        几分钟刷新一次热门题
  #  "hot_asks_sort_by"               热门题排序规则
  
  #  "hot_topics_followers_count"     限制热门课程为被关注数大于几的
  #  "hot_topics_asks_count"          限制热门课程为提问数大于几的
  #  "hot_topics_refresh_minute"      几分钟刷新一次热门课程
  #  "hot_topics_sort_by"             热门课程排序规则
 
  # "ask_advertise_limit_open"        是否开启所有用户提问频率限制
  # "ask_advertise_limit_time_range"  所有用户提问频率限制在几分钟内
  # "ask_advertise_limit_count"       所有用户提问频率限制题数
  # "ask_advertise_limit_deal_range"  所有用户提问频率限制处理几个小时内的题
  
  # "answer_advertise_limit_open"     是否开启所有用户解答/评论频率限制
  # "answer_advertise_limit_time_range"所有用户解答/评论频率限制在几分钟内
  # "answer_advertise_limit_count"    所有用户解答/评论频率限制解答/评论数
  # "answer_advertise_limit_deal_range"所有用户解答/评论频率限制处理几个小时内的解答/评论
  
  class << self
    def get_deleted_nin

      if get_deleted_nin_boolean
        [1,2,3]
      else
        [1,3]
      end
    end
    
    def get_deleted_nin_boolean
      item = SettingItem.where(key:'need_verification').first
      if item.blank?
        return false
      elsif item.value!="1"
        return false
      else
        item_start = SettingItem.where(key:'need_verification_start_time').first
        item_end = SettingItem.where(key:'need_verification_end_time').first
        if item_start and item_end
          start_time=item_start.value.to_i
          end_time=item_end.value.to_i
          local_time=Time.now.getlocal.hour
          if local_time>=start_time and end_time>local_time
            return true
          else
            return false
          end
        else
          return false
        end
      end
      #return (item and item.value=="1")
    end
  end
  
  
  
end
