# -*- encoding : utf-8 -*-
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  field :followers_count,:type=>Integer,:default=>0
  @before_soft_delete = proc{
    redis_search_index_destroy
    $redis_topics.hdel self.id,:name
    $redis_topics.hdel self.id,:summary
    $redis_topics.hdel self.name,:id
  }
  def self.roots
    Topic.where(:fathers=>[])
  end
  def self.math_and_sciences
    self.find_or_create_by(name:'数学与自然科学')
  end
  def self.engineering
    self.find_or_create_by(name:'工程')
  end
  def self.humanities
    self.find_or_create_by(name:'人文、艺术与社会科学')
  end
  def self.interdisciplinaries
    self.find_or_create_by(name:'交叉学科')
  end
  def self.others
    self.find_or_create_by(name:'其他')
  end
  #before_validation :check_and_fill_ancestors,:if=>'fathers_changed?'
  def children_visit(node,visited,ancestors)
    visited << node.name
    node.ancestors += node.name
    node.ancestors += ancestors
    node.ancestors.uniq!
    node.children.each do |item|
      if visited.include?(item.name)
        raise 'cycled'
      else
        children_visit(item,visited,node.ancestors)
      end
    end
    node.save(:validate=>false)
  end
  def check_and_fill_ancestors
    self.ancestors = [self.name] 
    self.fathers.each do |father|
      item = Topic.find_by_name(father)
      self.ancestors += item.ancestors 
    end
    self.ancestors.uniq!
    visited = []
    begin
      children_visit(self,self.ancestors)
    rescue => e
      self.errors.add(:fathers,'出现了循环父课程，请修改')
      return false
    end
    return true
  end
  before_save :counter_work
  def counter_work
    self.asks_count=self.asks.nondeleted.count
    self.followed_count = self.followers_count
    if new_record?
    end
  end
  #自动关注
  def check_autofollow
    User.where(:is_zombie=>true).sort_by{rand}.limit(50).each do |u|
      u.follow_topic(self,true)
    end
    self.update_attribute(:has_autofollow,1)
  end
  #更新首页热门课程
  def refresh_hot_topics
    $topics = Topic.nondeleted.where(:asks_count.gt=>SettingItem.find_or_create_by(:key=>"hot_topics_asks_count").value.to_i,:followed_count.gt=>SettingItem.find_or_create_by(:key=>"hot_topics_followers_count").value.to_i).to_a.collect{|x| [x.name,x.followers_count,(last_ask=AskLog.where(:action=>'ADD_TOPIC').where(:title=>x.name).last).blank? ? 0 : last_ask.created_at,(last_follow=UserLog.where(:action=>'FOLLOW_TOPIC').where(:target_parent_title=>x.name).last).blank? ? 0 : last_follow.created_at]}
    if SettingItem.find_or_create_by(:key=>"hot_topics_sort_by").value.to_s=="last_followed_at"
      $topics =$topics.sort{|x,y|y[3].to_i<=>x[3].to_i}
    else
      $topics =$topics.sort{|x,y|y[2].to_i<=>x[2].to_i}
    end

    # TopicCache.delete_all
    Mongoid.database.collection('topic_caches').drop
    $topics.each_with_index do |topic,i|
      TopicCache.create!(name:topic[0],hot_rank:i,followers_count:topic[1])
    end
  end
  def as_json(opts={})
    {id:self.id,name:self.name,followers_count:self.followers_count}
  end
  def asynchronously_clean_me
    bad_ids = [self.id]
    bad_names = [self.name]
    Util.bad_id_out_of!(User,:followed_topic_ids,bad_ids)
    Util.bad_id_out_of!(AskSuggestTopic,:topics,bad_names)
    Util.bad_id_out_of!(Ask,:topics,bad_names)
    self.logs.each do |c|
      Notification.where(:log_id=>c._id).each do |n|
        n.update_attribute(:deleted,1)
      end
      c.delete
    end
    # ------------
    self.asks.each{|ask| ask.inc(:topic_count,-1)}
  end
  def asks
    Ask.where(:topics => name)
  end
  def tags_array=(str)
    self.tags = str.split(',').collect{|str|str.strip}
  end

  def tags_array
    if self.tags
      self.tags.join(',')
    else
      ''
    end
  end

  def summary_plain
    Nokogiri.HTML(self.summary).text()
  end

  # index :created_at
  def add_father(topic)
    return if Setting.root_topic_id==self.id.to_s
    anA = topic.ancestors
    anB = self.ancestors
    raise Ktv::Shared::UserDataException if anA.include?(self.name)
    self.fathers << topic.name
    self.fathers.uniq!
    self.save!
  end

  def fathers_inst
    Topic.where(:name.in=>self.fathers)
  end
  def children_inst
    Topic.where(:fathers=>self.name)
  end
  def children
    self.children_inst.collect(&:name)
  end
  def self.get_ancestors(inst)
    [inst].tap do |x|
      for item in inst.fathers_inst
        x.concat Topic.get_ancestors(item)
      end
    end
  end
  def ancestors_inst
    Topic.get_ancestors(self).uniq
  end
  def ancestors
    self.ancestors_inst.collect(&:name)
  end
  def remove_father(topic)
    self.fathers.delete topic.name
    self.fathers.uniq!
    self.save!
  end
  field :quora,:type=>Hash,:default=>{}
  field :wikipedia,:type=>Hash,:default=>{}
  field :fathers,:type => Array,:default => []
  # field :fathers_count,:type=>Integer,:defaut=>0
  # field :children_count,:type=>Integer,:defaut=>0
  # field :ancestors_count,:type=>Integer,:defaut=>0
  # field :offspring_count,:type=>Integer,:defaut=>0
  def self.locate(arg)
    self.find_or_create_by(name:arg)
  end
  def self.fix_root!
    root = Topic.find Setting.root_topic_id
    Topic.where(:fathers=>[]).each do |item|
      item.add_father(root)
    end
  end
  def self.fix_ancestors!
    Topic.all.each do |item|
      item.ancestors = [ item.name ]
      item.save(:validate=>false)
    end
    Topic.where(:fathers=>[]).each do |item|
      self.fix_ancestors(item)
    end
  end
  def self.fix_ancestors(fitem)
    Topic.where(:fathers=>fitem.name).each do |item|
      item.ancestors += fitem.ancestors
      item.ancestors.uniq!
      item.save(:validate=>false)
      self.fix_ancestors(item)
    end
  end
  field :tags
  # index :tags
  field :hot_rank,:type=>Integer,:default=>9999
  
  attr_accessor :current_user_id, :cover_changed
  field :will_autofollow,:type=>Boolean,:default=>false
  field :has_autofollow,:type=>Boolean,:default=>false
  field :name
  def title
    self.name
  end
  field :summary
  field :cover
  mount_uploader :cover, CoverUploader

  field :coursewares_count, :type => Integer, :default => 0
  field :asks_count, :type => Integer, :default => 0
  field :followed_count, :type => Integer, :default => 0

  # index :name
  # index :follower_ids
  # index :asks_count

  has_many :logs, :class_name => "Log", :foreign_key => "target_id"

  # Followers
  has_and_belongs_to_many :followers, :inverse_of => :followed_topics, :class_name => "User"
  # field :follower_ids, :type => Array, :default => []
  
  validates_presence_of :name
  validates_uniqueness_of :name

  # 以下两个方法是给 redis search index 用
  def cover_small
    self.cover.small.url
  end
  def cover_small_changed?
    self.cover_changed? || self.cover_changed 
  end
  def cover_small38
    self.cover.small38.url
  end
  def cover_small38_was
    self.cover_was.small38.url
  end
  def cover_small38_changed?
    self.cover_changed? || self.cover_changed 
  end
  
  redis_search_index(:title_field => :name,
    :prefix_index_enable => true,
    :ext_fields => [:followers_count,:cover_small38, :coursewares_count],
    :score_field => :coursewares_count)
  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("name")
      return false
    end

    if self.spam?("summary")
      return false
    end
  end

  # Hack 上传图片，用于记录 cover 是否改变过
  def cover=(obj)
    super(obj)
    self.cover_changed = true
  end

  before_update :update_log
  def update_log
    return if self.current_user_id.blank?
    if false # we will never output this since only admin can edit and admin won't have logs
      insert_action_log("EDIT") if self.cover_changed or self.summary_changed?
    end
  end

  def self.save_topics(topics, current_user_id)
    new_topics = []
    topics.each do |item|
      topic = find_by_name(item.strip)
      # find_or_create_by(:name => item.strip)
      if topic.nil?
        topic = create(:name => item.strip)
        begin
          log = TopicLog.new
          log.user_id = current_user_id
          log.title = topic.name
          log.topic = topic
          log.action = "NEW"
          log.diff = ""
          log.save
        rescue Exception => e
          Rails.logger.warn { "Topic save_topics failed! #{e}" }
        end
      end
      new_topics << topic.name
    end
    new_topics
  end

  def self.find_by_name(name)
    find(:first,:conditions => {:name => name.force_encoding_zhaopin} )
  end

  def self.search_name(name, options = {})
    limit = options[:limit] || 10
    where(:name => /#{name}/i ).desc(:asks_count).limit(limit)
  end
  
  cache_consultant :name
  cache_consultant :summary
  def self.set_id(k,v)
    $redis_topics.hset(k,:id,v)
  end
  def self.get_id(namearg)
    ret = $redis_topics.hget(namearg,:id)
    if ret.nil?
      topic = Topic.where(name:namearg).first
      return nil if topic.nil?
      ret = topic.id
      self.set_id(namearg,ret)
    end
    ret
  end

  after_save{
    self.class.set_id(self.name,self.id)
  }
  def update_consultant!
    self.class.set_name(self.id,self.name)
    self.class.set_id(self.name,self.id)
  end
 
  protected
  def insert_action_log(action)
    begin
      log = TopicLog.new
      log.user_id = self.current_user_id
      log.title = self.name
      log.target_id = self.id
      log.target_attr = (self.cover_changed == true ? "COVER" : (self.summary_changed? ? "SUMMARY" : "")) if action == "EDIT"
      log.action = action
      log.diff = ""
      log.save
    rescue Exception => e
      Rails.logger.info { "#{e}" } 
    end
  end

end
