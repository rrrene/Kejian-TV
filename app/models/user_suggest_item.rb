# -*- encoding : utf-8 -*-
require 'benchmark'
class UserSuggestItem
  include Mongoid::Document
  belongs_to :user
  field :suggested_experts, :type => Array, :default => []
  field :suggested_users, :type => Array, :default => []
  field :suggested_topics, :type => Array, :default => []
  
  def self.find_by_user(user,opts={})
    unless user.respond_to?(:id)
      user = User.find_by_name(user)
    end
    return [] if !opts[:force] and self.where(:user_id => user.id).first.nil?
    item = self.find_or_initialize_by(:user_id => user.id)

    if opts[:force]

      # 生成内容
      user = item.user
      if opts[:force]
        item.suggested_experts = []
        item.suggested_users = []
        item.suggested_topics = []
      else
        item.suggested_experts ||= []
        item.suggested_users ||= []
        item.suggested_topics ||= []
      end

      if opts[:force] or opts[:force_e] or item.suggested_experts.blank?
        begin
          ex = TopicSuggestExpert.where(:sizze.gt=>0,:topic_id.in=>user.followed_topic_ids).random(5).collect(&:expert_ids).flatten.uniq
          ex -= (ex & user.following_ids)
          ex.delete(user.id)
          item.suggested_experts += ex
        rescue => e
          p e
          p e.backtrace
        end
      end
      if opts[:force] or opts[:force_u] or item.suggested_users.blank?
        begin
          User.where(:following_count.gt=>0,:is_expert.ne=>true,:_id.in=>user.following_ids).limit(5).each do |user|
            ex = user.following_ids
            ex -= (ex & user.following_ids)
            ex.delete(user.id)
            item.suggested_users += ex
            item.suggested_users.uniq!
            break if item.suggested_users.size>15
          end
        rescue => e
          p e
          p e.backtrace
        end
      end
      if opts[:force] or opts[:force_t] or item.suggested_topics.blank?
        begin
          ex = TopicSuggestTopic.where(:sizze.gt=>0,:topic_id.in=>user.followed_topic_ids).random(5).collect(&:topics).flatten.uniq
          ex -= (ex & user.followed_topic_ids.collect{|id| Topic.get_name(id)})
          item.suggested_topics += ex
        rescue => e
          p e
          p e.backtrace
        end
      end
      unless item.suggested_experts.empty? and item.suggested_users.empty? and item.suggested_topics.empty?
        if opts[:debug]
          puts "#{item.user.name} -> #{item.suggested_experts.size} #{ item.suggested_users.size} #{ item.suggested_topics.size}"
        end
        item.save
      end
    end
    return [item.suggested_experts,item.suggested_users,item.suggested_topics]
  end
end
