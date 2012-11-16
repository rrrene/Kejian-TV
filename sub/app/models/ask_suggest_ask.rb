# -*- encoding : utf-8 -*-
class AskSuggestAsk
  ANSWER_COUNT = 3
  UP_COUNT = 8
  include Mongoid::Document
  belongs_to :ask
  field :ask_ids, :type => Array, :default => []

  def self.find_by_ask(ask,opts={})
    return [] if !opts[:force] and self.where(:ask_id => ask.id).first.nil?
    item = self.find_or_initialize_by(:ask_id => ask.id)
    if opts[:force]
      # 生成内容
      ptn = Hash.new(0)
      how = Hash.new("")
      Ask.any_in(:topics=>item.ask.topics).where(:_id.ne=>item.ask_id).each do |ask|
        ptn[ask.id] = (ask.topics & item.ask.topics).size
        how[ask.id] += "#{ptn[ask.id]}"
        if ask.answers_count>ANSWER_COUNT
          dazhe = ANSWER_COUNT
        elsif ask.answers_count>0
          dazhe = ask.answers_count
        else
          dazhe = 1
        end
        if ans = ask.answers.order_by(:"votes.up_count".desc).first
          if ans.votes['point'] and ans.votes['point']>UP_COUNT
            dazhe *= UP_COUNT
          elsif ans.votes['point']
            dazhe *= ans.votes['point']
          end
        end
        if ask.created_at<(Time.now-2.month)
          dazhe *= 0.5
        end
        ptn[ask.id] *= dazhe
        how[ask.id] += " * #{dazhe}"
      end
      item.ask_ids = ptn.keys.sort{|x,y| ptn[y]<=>ptn[x]}.limit(10)
      
      if opts[:debug]
        puts "#{item.ask.title}: #{item.ask_ids.collect{|id| ask=Ask.find(id);ask.title+'('+how[id].to_s+')'}.join(',')}"
        puts "------------------------------------------"
      end
      item.save
    end
    return item.ask_ids
  end
  
end
