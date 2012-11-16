# -*- encoding : utf-8 -*-
class SearchHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  
  field :user_id
  field :is_guest,:type=>Boolean,:default=>false
  
  field :referer,:type=>String
  field :keyword,:type=>String
  field :ip,:type=>String
  
  field :action,:type=>String
  field :choose,:type=>String
  
  field :is_analyze,:type=>Boolean,:default=>false
  scope :not_for_analyze,where(:is_analyze=>false)
  
  # index :keyword
  
  def self.add_search_jump_history(user,keyword,referer,ip,choose)
    sh  = SearchHistory.new
    if user.nil?
      sh.is_guest = true
    else
      sh.user_id = user.id
    end
    sh.keyword = keyword
    sh.referer = referer
    sh.choose  = choose
    sh.ip = ip
    sh.is_analyze = true
    sh.save(:validate=>false)
  end
  def self.add_search_keyword(user,keyword,ip,action)
    keyword = keyword.strip()
    if user.nil?
      return false
    end
    if !user.mark_search_keyword
      return false
    end
    if !(shold = SearchHistory.not_for_analyze.nondeleted.where(user_id:user.id,keyword:keyword).first).nil?
      shold.ip = ip
      shold.action = action
      shold.updated_at = Time.now
      shold.save(:validate=>false)
      return false
    end
    sh  = SearchHistory.new
    sh.keyword = keyword
    sh.user_id = user.id
    sh.action = action
    sh.ip = ip
    sh.is_analyze = false
    sh.save(:validate=>false)
    return true
  end
  def self.locate_search_history(user_id)
    SearchHistory.not_for_analyze.nondeleted.where(user_id:user_id).desc('updated_at')
  end
  def self.on_off_history(user_id,op='off')
    if op == 'off'
      User.find(user_id).ua(:mark_search_keyword,false)
    elsif op == 'on'
      User.find(user_id).ua(:mark_search_keyword,true)
    end
  end
  def self.remove_one_search_history(id)
    return false if !Moped::BSON::ObjectId.legal?(id)
    shold = SearchHistory.find(id)
    if shold.nil?
      return false
    end
    if shold.ua(:deleted,1)
      return true
    else
      return false
    end
  end
  def self.clear_history(user_id)
    sh = SearchHistory.not_for_analyze.nondeleted.where(user_id:user_id)
    sh.each do |s|
      s.ua(:deleted,1)
    end
    return true
  end
  
  
  USER_ACTION = {
    'show' => '课件',
    'show_contents' => '课件内容',
    'show_playlists' => '课件锦囊',
    'show_' => '课程等'
  }
end
