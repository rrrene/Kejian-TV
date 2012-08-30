# coding: utf-8
class TopicsController < ApplicationController
  before_filter :we_are_inside_lingyu
  def we_are_inside_lingyu
    @we_are_inside_lingyu = true
  end  
  def hot
    @we_are_inside_lingyu = true    
  end
  def update_fathers
    @name = params[:name].strip
    @add = params[:add] == "1" ? true : false
    @topic = Topic.find(params[:id])
    if @add
      @new_topic = Topic.find_or_create_by(name:params[:name])
      @topic.add_father(@new_topic)
      render :json=>@new_topic
    else
      @new_topic = Topic.find(params[:name])
      @topic.remove_father(@new_topic)
      render :json=>@new_topic
    end
  end
  def update_title
    @topic = Topic.find(params[:id])
    old = Topic.where(name:params[:name]).first
    if old
      render json:{suc:false,why:'这个名字已经被占用'}
    else
      # todo: potentially slow operation
      Courseware.where(:topic => @topic.name).each do |x|
        x.update_attribute(:topic,params[:name])
      end
      @topic.update_attribute(:name,params[:name])
      render json:{suc:true,name:@topic.name}
    end
  end
  def fol
    suc=0
    params[:q].split(',').each do |id|
      t=Topic.where(name:(id.strip)).first

      if t
        current_user.follow_topic(t)
        suc+=1
      end
    end
    render text:suc
  end

  def unfol
    suc=0
    params[:q].split(',').each do |id|
      t=Topic.where(name:(id.strip)).first
      if t
        current_user.unfollow_topic(t)
        suc+=1
      end
    end
    render text:suc
  end


  def index
    @seo[:title] = '全部领域'
    @per_page = 20
    @topics = Topic.all.paginate(:page => params[:page], :per_page => @per_page)
  end

  def show
    name = params[:id].force_encoding_zhaopin.strip
    @per_page = 10
    if params[:force_id] and params[:force_id]=1
      @topic = Topic.where(:_id=>params[:id]).first
    else
      @topic = Topic.find_by_name(name)
    end
    @topic ||= Topic.where(:_id=>params[:id]).first
    if @topic.blank? or @topic.deleted==1
      return render_404
    end
    cookies[:presentation_topic] = @topic.name
    father = @topic.fathers.first
    @fathers = []
    while father
      topic = Topic.find_by_name(father)
      @fathers << topic
      father = topic.fathers.first
    end
    @asks = Ask.where(:topics => name).normal
    @topic_unanswered_asks_count = @asks.unanswered.count
    if params[:filter]=='new'
      @asks = @asks.unanswered
    end
    @asks = @asks.recent.nondeleted.paginate(:page => params[:page], :per_page => @per_page)
    @ask_ids = @asks.collect(&:id)
    set_seo_meta(@topic.name,:description => @topic.summary)
    # if @ec=ExpertCache.where(tag:name).first
    #   @related_expert_ids = @ec.experts
    #   @related_expert_ids = @related_expert_ids[0..4] if @related_expert_ids.size > 5
    # else
    #   @related_expert_ids = []
    # end
    @related_expert_ids = TopicSuggestExpert.find_by_topic(@topic).limit(5)
    @related_topics = TopicSuggestTopic.find_by_topic(@topic)
    @related_expert_ids -= current_user.following_ids if user_signed_in?
    @related_topics = @related_topics.limit(7)
    
    if '1'==params[:force_mobile]
      if '1'==params[:force_js]
        render '/asks/index.mobile.js',layout:false
      else
        render 'show.mobile',layout:'application.mobile'
      end
    else
      # if !params[:page].blank?
      #   render "/asks/index.js"
      # else
      render "show#{@subsite}"
      # end
    end
    
  end
  
  def follow
    @topic = Topic.find_by_name(params[:id])
    if not @topic
      render :text => "0"
      return
    end
    current_user.follow_topic(@topic)
    render :text => "1"
  end
  
  def unfollow
    @topic = Topic.find_by_name(params[:id])
    if not @topic
      render :text => "0"
      return
    end
    current_user.unfollow_topic(@topic)
    render :text => "1"
  end

  def edit
    @topic = Topic.find(params[:id])
    render :layout => false
  end

  def update
    return unless current_user
    @topic = Topic.find(params[:id])
    @topic.current_user_id = current_user.id
    if !params[:topic]
      redirect_to  topic_path(@topic.name)
      return
    end
    @topic.cover = params[:topic][:cover]
    if @topic.save
      flash[:notice] = "领域封面上传成功。"
    else
      flash[:alert] = "领域封面上传失败，请检查你上传的图片适合符合格式要求。"
    end
    redirect_to topic_path(@topic)
  end
end
