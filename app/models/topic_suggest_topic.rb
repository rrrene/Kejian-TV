# -*- encoding : utf-8 -*-
class TopicSuggestTopic
  include Mongoid::Document
  field :sizze, :type => Integer, :default => 0
  belongs_to :topic
  field :topics, :type => Array, :default => []
  def self.find_by_topic(topic,opts={})
    unless topic.respond_to?(:id)
      topic = Topic.find_by_name(topic)
    end
    return [] if !opts[:force] and self.where(:topic_id => topic.id).first.nil?
    item = self.find_or_initialize_by(:topic_id => topic.id)
    if opts[:force]
      # 生成内容
      ret = Hash.new(0)
      item.topic.follower_ids.each do |id|
        begin
          user = User.find(id)
          user.followed_topic_ids.each do |tid|
            ret[tid]+=1
          end
        rescue => e
        end
      end
      sorted_keys = ret.keys.sort{|x,y| ret[x]<=>ret[y]}.reverse
      sorted_keys.delete(item.topic_id)
      item.topics = sorted_keys.collect do |id|
        Topic.get_name(id)
        # begin
        #   topic = Topic.find()
        #   topic.name
        # rescue => e
        #   nil
        # end
      end.compact
      if opts[:debug]
        puts "#{item.topic.name}: #{item.topics.collect{|name| topi=Topic.find_by_name(name);topi.name+'('+ret[topi.id].to_s+')'}.join(',')}"
        puts "------------------------------------------"
      end
      item.sizze = item.topics.size
      item.save
    end
    return item.topics
  end
end
