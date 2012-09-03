# -*- encoding : utf-8 -*-
class SearchController < ApplicationController

  def index
    # @asks = Ask.search_title(params["w"].to_s.strip,:limit => 20)
    set_seo_meta("关于“#{params[:w]}”的搜索结果")
    render "/asks/index"
  end

  def all
    # sum = 0
    # sum += Redis::Search.query("Topic",params[:q].strip,:limit => 10,:sort_field=>'followers_count', :only_count=>true)
    # sum += Redis::Search.complete("User",params[:q].strip,:limit => 10, :only_count=>true)
    # sum += Redis::Search.query("Ask",params[:q].strip,:limit => 10, :only_count=>true)
    # 
    the_limit = 7
    result = Redis::Search.query("Topic",params[:q].strip,:limit => 2,:sort_field=>'followers_count')
    if result.length <= the_limit
      result_ren = Redis::Search.query("User",params[:q].strip,:limit => [the_limit - result.length + 1,2].min,:sort_field=>'search_score')
      if result_ren.size < 2
        Redis::Search.query("Topic",params[:q],:limit => 1).each do |item|
          topic = Topic.where(name:item['title']).first
          @related_expert_ids = TopicSuggestExpert.find_by_topic(topic,:sort_field=>'search_score')
          @related_expert_ids.each do |id|
            result_ren += Redis::Search.complete("User",User.get_name(id),:limit => 1)
          end
          result_ren.uniq!
          result_ren=result_ren[0..1] if result_ren.size > 2
          break if result_ren.size >= 2
        end
      end
      result += result_ren
      if result.length <= the_limit
        result0 = Redis::Search.query("Courseware",params[:q].strip,:limit => the_limit - result.length + 1,:sort_field=>'views_count')
        tmp1=[]

        result0.each do |item|
          tmp1 << item if Time.parse(item['created_at'].split('T').first) >= 1.month.ago
          tmp1.sort!{|x,y| x['views_count']<=>y['views_count']}
        end
        result += tmp1.reverse
        tmp1=[]
        result0.each do |item|
          tmp1 << item if Time.parse(item['created_at'].split('T').first) < 1.month.ago
          tmp1.sort!{|x,y| x['views_count']<=>y['views_count']}
        end
        result += tmp1.reverse
      end
      # if result.length <= the_limit
      #   result0 = Redis::Search.query("Ask",params[:q].strip,:limit => the_limit - result.length + 1,:sort_field=>'answers_count')
      #   tmp1=[]
      # 
      #   result0.each do |item|
      #     tmp1 << item if Time.parse(item['created_at'].split('T').first) >= 1.month.ago
      #     tmp1.sort!{|x,y| x['answers_count']<=>y['answers_count']}
      #   end
      #   result += tmp1.reverse
      #   tmp1=[]
      #   result0.each do |item|
      #     tmp1 << item if Time.parse(item['created_at'].split('T').first) < 1.month.ago
      #     tmp1.sort!{|x,y| x['answers_count']<=>y['answers_count']}
      #   end
      #   result += tmp1.reverse
      # end
    end

#render text:result ;return

    lines = []
    result.each do |item|
if item['title'].length>55
item['title']=item['title'][0..54]
item['title']+='...'
end
      case item['type']
      when "Ask"
        lines << complete_line_ask(item)
      when "Courseware"
        lines << complete_line_cw(item)
      when "User"
        item['avatar_small38']='/defaults/avatar/small38.jpg' if item['avatar_small38'].blank?
        lines << complete_line_user(item)
      when "Topic"
        item['cover_small38']='/defaults/cover/small38.gif' if item['cover_small38'].blank?
        lines << complete_line_topic(item)
      end
    end
    lines << "#{params[:q]}#!#Total" unless lines.empty?
    render :text => lines.join("\n")
  end

  def topics
    result = Redis::Search.complete("Topic",params[:q],:limit => 10)
    if params[:format] == "json"
      lines = []
      result.each do |item|
        lines << complete_line_topic(item)
      end
      render :text => lines.join("\n")
    else
      lines = []
      result.each do |item|
        lines << complete_line_topic(item)
      end
      render :text => lines.join("\n") 
    end
  end

  def asks
    result = Redis::Search.query("Ask",params[:q].strip,:limit => 10)
    puts result.inspect
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << complete_line_ask(item)
      end
      render :text => lines.join("\n") 
    end
  end

  def users 
    params[:q] = params[:q].strip if params[:q]
    
    result = []
    
    qs = params[:q].split(/\s+/)
    qs.unshift qs.join('') if qs.size > 1
    qs.each do |q|
      next if q.blank?
      result += Redis::Search.query("User",q,:limit => 20)
      result.uniq!
      break unless result.size < 10
    end
    
    [params[:q],params[:q].split(/\s+/).join('')].uniq.each do |params_q|
      next if params_q.blank?
      if result.size < 10
        Redis::Search.query("Topic",params_q,:limit => 3).each do |item|
          topic = Topic.where(name:item['title']).first
          @related_expert_ids = TopicSuggestExpert.find_by_topic(topic)
          @related_expert_ids.each do |id|
            result += Redis::Search.query("User",User.get_name(id),:limit => 1,:sort_field=>'search_score')
          end
          result.uniq!
          result=result[0..9] if result.size > 10
          break if result.size >= 10
        end
      end
    end
    
    if params[:format] == "json"
      render :json => result.to_json
    else
      lines = []
      result.each do |item|
        lines << complete_line_user(item)
      end
      render :text => lines.join("\n") 
    end
  end

  private
    def complete_line_ask(item,hash = true)
      if hash
        item['title'] = item['title'].strip
        "#{item['title']}#!##{item['id']}#!##{item['answers_count']}#!##{item['topics'].join(',')}#!#Ask"
      else
        item.title = item.title.strip
        "#{item.title.gsub("\n",'')}#!##{item.id}#!##{item.answers_count}#!##{item.topics.join(',')}#!#Ask"
      end
    end

    def complete_line_cw(item,hash = true)
      if hash
        item['title'] = item['title'].strip
        "#{item['title']}#!##{item['id']}#!##{item['views_count']}#!##{item['topic']}#!##{item['cover_small']}#!#Courseware"
      else
        item.title = item.title.strip
        "#{item.title.gsub("\n",'')}#!##{item.id}#!##{item.views_count}#!##{item.topic}#!##{item['cover_small']}#!#Courseware"
      end
    end
    
    def complete_line_topic(item,hash = true)
      if hash
        item['title'] = item['title'].strip
        "#{item['title']}#!##{item['id']}#!##{item['followers_count']}#!##{item['coursewares_count']}#!##{item['cover_small38']}#!#Topic"
      else
        item.name = item.name.strip
        "#{item.name}#!##{item.id}#!##{item.followers_count}#!##{item.coursewares_count}#!##{item.cover_small38}#!#Topic"
      end
    end

    def complete_line_user(item,hash = true)
      if hash
        item['title'] = item['title'].strip
        item['title'] = item['title'].split('@@')[0]
        "#{item['title']}#!##{item['id']}#!##{item['tagline']}#!##{item['avatar_small38']}#!##{item['followers_count']}#!##{item['coursewares_count']}#!##{item['slug']}#!#User"
      else
        item.name = item.name.strip
        item.name = item.name.split('@@')[0]
        "#{item.name}#!##{item.id}#!##{item.tagline}#!##{item.avatar_small38}#!##{item.followers_count}#!##{item.coursewares_count}#!##{item.slug}#!#User"
      end
    end

end
