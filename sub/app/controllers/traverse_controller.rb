# -*- encoding : utf-8 -*-
class TraverseController < ApplicationController
  def index

#if '1'==params[:force_mobile]
#  @asks = Redis::Search.query("Ask",params[:q].strip,:limit => 100,:sort_field=>'answers_count')
#else
    if params[:q]
      params[:q] = params[:q].force_encoding_zhaopin
=begin
      @hash = {'Topic'=>'name','User'=>'name','Ask'=>'title'}
      @hash.keys.each do |classname|
        klass = classname.constantize
        eval <<-HERE
        @#{klass.collection_name} = #{klass}.where(#{@hash[classname]}:/#{params[:q]}/).to_a
        HERE
      end
=end
      @qq = MMSeg.split(params[:q])
      @topics = Topic.where(:name.in=>Redis::Search.query("Topic",params[:q],:limit=>100,:sort_field=>'followers_count').collect{|topic_hash| topic_hash['title']}).to_a.sort{|x,y|
        ret = (x.name.length - (x.name.chars.to_a & params[:q].chars.to_a).size) <=> (y.name.length - (y.name.chars.to_a & params[:q].chars.to_a).size)
        if 0==ret
          -(x.followers_count <=> y.followers_count)
        else
          ret
        end
      }
      @asks  = Ask.where(:_id.in=>Redis::Search.query("Ask",params[:q],:limit=>100).collect{|topic_hash| topic_hash['id']}).desc('views_count').to_a
      @users = User.where(:_id.in=>Redis::Search.query("User",params[:q],:limit=>100).collect{|topic_hash| topic_hash['id']}).desc('followers_count').to_a
      topic_names = user_ids = ask_ids =  []
      if @qq.size>=2
        @qq.each do |q|
          topic_names += Redis::Search.query("Topic",q.strip,:limit=>100,:sort_field=>'followers_count').collect{|topic_hash| topic_hash['title']}
          user_ids += Redis::Search.complete("User",q.strip,:limit=>100).collect{|topic_hash| topic_hash['id']}
          ask_ids += Redis::Search.query("Ask",q.strip,:limit=>100).collect{|topic_hash| topic_hash['id']}
        end
        topic_names -= @topics.collect(&:name)
        user_ids -= @users.collect{|x| x.id.to_s}
        ask_ids -= @asks.collect{|x| x.id.to_s}
        topic_names.uniq!
        user_ids.uniq!
        ask_ids.uniq!
      end
      
      unless topic_names.empty?
        @topics += Topic.where(:name.in=>topic_names,:asks_count.gt=>14).to_a.sort{|x,y|
          ret = (x.name.length - (x.name.chars.to_a & params[:q].chars.to_a).size) <=> (y.name.length - (y.name.chars.to_a & params[:q].chars.to_a).size)
          if 0==ret
            -(x.followers_count <=> y.followers_count)
          else
            ret
          end
        }
        @topics += Topic.where(:name.in=>topic_names,:asks_count.lt=>15).to_a.sort{|x,y|
          ret = (x.name.length - (x.name.chars.to_a & params[:q].chars.to_a).size) <=> (y.name.length - (y.name.chars.to_a & params[:q].chars.to_a).size)
          if 0==ret
            -(x.followers_count <=> y.followers_count)
          else
            ret
          end
        }
      end
      unless ask_ids.empty?
        @asks += Ask.where(:_id.in=>ask_ids).desc('views_count').to_a
      end
      unless user_ids.empty?
        @users += User.where(:_id.in=>user_ids).desc('followers_count').to_a
      end
    end
    
    @per_page = 20
    if '2'==params[:mode]
      @users = @users.paginate(:page => params[:page], :per_page => @per_page)
    end
    if '3'==params[:mode]
      if 'timewise'==params[:sortc]
        @asks.sort!{|x,y| y.created_at<=>x.created_at}
      elsif 'answise'==params[:sortc]
        @asks.sort!{|x,y| y.answers_count<=>x.answers_count}
      end
      @asks = @asks.paginate(:page => params[:page], :per_page => @per_page)
    end
#end
    
    if '1'==params[:force_mobile]
      render 'index.mobile',layout:'application.mobile'
    else
      render
    end
    
  end

  def asks_from
    start = params[:current_key].to_i*20
    @asks= Redis::Search.query("Ask",params[:q],:limit=>start+20+1)
    @more =(@asks.size-start>20)
 if @asks.size-start>20
    @asks=@asks[start..start+19]
else
 @asks=@asks[start..-1]
end
    @asks||=[]
    render layout:false
  end
end
