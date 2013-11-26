# -*- encoding : utf-8 -*-
class TopicSuggestExpert
  include Mongoid::Document
  MIN = 20
  MAX = 1000
  belongs_to :topic
  field :expert_ids, :type => Array, :default => []
  field :sizze, :type => Integer, :default => 0
  def self.calculate_expert_topics
    ret = {}
    # User.where(:is_expert=>true).each do |expert|
    #   ret[expert.id] = expert.answers.collect{|ans| ans.ask ? ans.ask.topics : nil}.compact.flatten
    # end
    User.all.each do |expert|
      ret[expert.id] = expert.coursewares.nondeleted.normal.collect{|cw| cw.topics ? cw.topics : nil}.compact.flatten
    end
    ret
  end
  
  def self.find_by_topic(topic,opts={})
    unless topic.respond_to?(:id)
      topic = Topic.find_by_name(topic)
    end
    return [] if topic.nil?
    return [] if !opts[:force] and self.where(:topic_id => topic.id).first.nil?
    item = self.find_or_initialize_by(:topic_id => topic.id)
    name = topic.name

    if opts[:force]
      if opts[:expert_topics].blank?
        opts[:expert_topics] = calculate_expert_topics
      end
      # 生成内容
      item.expert_ids = []
      ptn = Hash.new(0)
      how = Hash.new("")
      # item.expert_ids += User.where(tags:name).collect(&:_id)
      opts[:expert_topics].each do |key,value|
        if value.count(name) > 0 #threshold: 4
          item.expert_ids << key
          ptn[key] = value.count(name)
          how[key] += "#{value.count(name)}"
        end
      end
      item.expert_ids.uniq!
      item.expert_ids.each do |id|
        u=User.find(id);
        
        dazhe = u.follower_ids.count
        dazhe = ((dazhe-MIN)*1.0 ) / (MAX-MIN)
        dazhe = 0 if dazhe < 0 
        dazhe = 1 if dazhe > 1
        dazhe = 1 # todo
        ptn[id] *= dazhe
        how[id] += " * #{dazhe}"
      end
      item.expert_ids.sort! do |x,y|
        ptn[y]<=>ptn[x]
      end
      if uid = item.expert_ids.first
        u = User.find uid
        if ptn[uid]>u.expert_topic_score
          u.update_attribute(:expert_topic,item.topic.name)
          u.update_attribute(:expert_topic_score,ptn[uid])
        end
      end
      if opts[:debug]
        puts "#{item.topic.name}: #{item.expert_ids.collect{|id| u=User.find(id);u.name+'('+how[id].to_s+')'}.join(',')}"
        puts "------------------------------------------"
      end
      item.sizze = item.expert_ids.size
      item.save
    end

    return item.expert_ids
  end
end
