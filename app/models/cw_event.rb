# -*- encoding : utf-8 -*-
require 'search_terms'
class CwEvent
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :title
  field :title_id
  field :user_id
  field :is_guest, :type=> Boolean,:default=>false
  field :ip, :type => String                        # request.ip
  field :is_mobile, :type=> Boolean,:default=>false

  field :request_url,:type=>String
  field :event_type, :type => Integer               # EVENT_TYPE
  field :action, :type => Integer                   # ACTION_TYPE
  field :succuss,:type => Boolean,:default=>true    # Action succuss or failed
  field :referer, :type => String                   # href  request.referrer env['HTTP_REFERER']
  field :engine_or_share,:type => Integer           # ES_DOMAIN && ES_NAME
  field :keyword, :type => String                   # generate 
  field :source, :type => String                    # request referer hostname
  field :date,:type=>Integer, :default => Time.now.beginning_of_day().to_i

  def self.add_action(action,title,id,ip,url,user_id,suc=true,mobile)
   ce = CwEvent.new 
   ce.title = title
   ce.title_id = id
   ce.ip = ip
   ce.request_url = url
   ce.is_mobile = mobile
   ce.event_type = 0
   ce.action = CwEvent::ACTION_LIST[action]
   ce.succuss = suc 
   if user_id.nil?
       ce.is_guest = true
   else
       ce.is_guest = false
       ce.user_id = user_id
   end
   ce.save(:validate=>false)
  end
  
  # def update_source(url)
  #     self.update_attribute(:source,url)
  # end
  
  def self.add_come_event(title,id,ip,url,user_id,referer='',mobile)
      ce = CwEvent.new
      ce.title = title
      ce.title_id = id
      ce.ip = ip
      ce.is_mobile = mobile
      ce.request_url = url
      ce.engine_or_share = -2
      ce.action = 0
      if user_id.nil?
          ce.is_guest = true
      else
          ce.is_guest = false
          ce.user_id = user_id
      end
      ce.referer = referer
      ce.source = self.generate_host(referer)
      CwEvent::ES_DOMAIN.each do |k,v|
          if ce.source.include?(k)
              ce.engine_or_share = v
              break
          end
      end
      
      if ce.source.include?('kejian.tv') or ce.source.include?('kejian.lvh.me')
          ce.engine_or_share = -1
          if ce.referer.include?('/search/')
              ce.keyword = URI.parse(ce.referer).path.split('/')[-1]
              ce.event_type = CwEvent::EVENT_LIST['站内搜索']
          elsif ce.referer.include?('recommand')
              ce.event_type = CwEvent::EVENT_LIST['站内推荐']
          else
              ce.event_type = CwEvent::EVENT_LIST['PageView']
          end
      end
      
      if ce.engine_or_share <100 and ce.engine_or_share >=0
          ce.event_type = CwEvent::EVENT_LIST['站外搜索']
          ce.keyword = self.generate_keyword(referer)
      elsif ce.engine_or_share >=100
          ce.event_type = CwEvent::EVENT_LIST['站外分享']
      end
      
      if ce.engine_or_share == -2
          ce.keyword = self.generate_keyword(referer)
          ce.event_type = CwEvent::EVENT_LIST['流量来源']
      end
      ce.save(:validate=>false)
  end
  
  EVENT_TYPE= {
      0 => '普通操作',
      1 => '流量来源',
      2 => '站内搜索',
      3 => '站内推荐',
      4 => '站外搜索',
      5 => '站外分享',
      6 => 'PageView',
      7 => '内嵌观看'
  }
  EVENT_LIST= Hash[CwEvent::EVENT_TYPE.to_a.map{|k,v| [v,k]}]
  
  ACTION_TYPE = {
      0 => 'PageView',          # Actually this action is no use
      1 => '评论课件',
      2 => '举报课件',
      3 => '课件顶',
      4 => '课件踩',
      5 => '添加收藏',
      6 => '下载',
      7 => '评论顶',
      8 => '评论踩',
      9 => '评论评论',
      10 => '评论举报',
      11 => '评论删除',
      12 => '邮件分享',
      13 => '查看父评论',
      100 => 'NOT ACTION'
  }
  ACTION_LIST = Hash[CwEvent::ACTION_TYPE.to_a.map{|k,v| [v,k]}]
  ES_NAME = {
      -2 => 'IDK',
      -1 => '站内',
      0 => 'Google',
      1 => '百度',
      2 => 'Bing',
      3 => '搜狗',
      100 => '人人',
      101 => '豆瓣',
      102 => '微博'
  }
  ES_DOMAIN = {
      'google'  => 0,
      'baidu'   => 1,
      'bing'    => 2,
      'sogou'   => 3,
      'renren'  => 100,
      'douban'  => 101,
      'weibo'   => 102
  }
  def self.generate_keyword(url)
      referrer = URI.parse(URI.encode(url.strip))
      return referrer.search_string
  end
  def self.generate_host(url)
      return URI.parse(URI.encode(url.strip)).host.downcase
  end
end
