# -*- encoding : utf-8 -*-
class Api::TopicsController < ApiController
  def index
    pagination_get_ready
    if params[:newbie].present?
      @topics = TopicCache.all
    else
      @topics = Topic
      @topics = @topics.where(:name=>/#{params[:q]}/) if params[:q]
      @topics = @topics.where(:tags => params[:tag]) if params[:tag]
      @topics = @topics.desc(params[:sort]) if params[:sort]
      @topics = @topics.desc("created_at")
      @topics = @topics.nondeleted
    end
    pagination_over(@topics.count)
    @topics = @topics.paginate(:page => @page, :per_page => @per_page)
    @ret = @topics
    render_this!
  end
  def suggest_topics
    get_topic
    @related_topics = TopicSuggestTopic.find_by_topic(@topic)
    render json:@related_topics
  end
  def suggest_experts
    get_topic
    @related_topics = TopicSuggestExpert.find_by_topic(@topic)
    render json:@related_topics
  end
protected
end
