# -*- encoding : utf-8 -*-

class Api::AsksController < ApiController
  before_filter :get_current_user,:except=>[:index,:show,:sugg]
  before_filter :get_ask,:except=>[:index,:create]
  def index
    pagination_get_ready
    if params[:newbie].present?
      @asks = AskCache.limit(20).collect{|ask_cache| Ask.nondeleted.where(:_id=>ask_cache.ask_id).first}.compact
    else
      @asks = Ask.nondeleted.normal    
      @asks = @asks.unanswered if !params[:zero_answers].blank?
      @asks = @asks.where(:topics=>params[:topic_name]) unless params[:topic_name].blank?
      @asks = @asks.recent.where(:no_display_at_index.ne=>true)
    end
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
def create
  if params[:ask][:to_user_slug].present?
    user = User.where(slug:params[:ask][:to_user_slug]).first
    render json:{error:'user not found'} and return if user.blank?
    params[:ask][:to_user_id] = user.id
  end
  ret,@ask,@invite = Ask.real_create(params,@current_user)
  if ret==2
    render json:{success:true}
  elsif 1==ret
    render json:{success:false,errors:['同名的题已经被创建过了'], ask_id:@ask.id}
  else
    render json:{success:false,errors:@ask.errors.full_messages}
  end
end
  def show
    render json:@ask.to_json(:wendao_show=>true)
  end
  def update
    params[:ask][:current_user_id] ||= @current_user.id
    ret = ask.update_attributes(params[:ask])
    if ret
      render json:{success:ret}
    else
      render json:{success:false,errors:ask.errors.full_messages}
    end
  end
  def answer
    success,answer = @ask.answer(params[:answer][:body],@current_user)
    if success
    render json:{success:success}
    else
      render json:{success:false,errors:answer.errors.full_messages}
    end
  end
  def comment
    c=Comment.new
    c.commentable_type='Ask'
    c.commentable_id=@ask.id
    c.user_id = @current_user.id
    c.body = params[:comment][:body]
    success = c.save
    if success
      render json:{success:success}
    else
      render json:{success:false,errors:c.errors.full_messages}
    end
  end
  def sugg
    pagination_get_ready
    @asks = AskSuggestAsk.find_by_ask(@ask)
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
  def logs
    pagination_get_ready
    @asks = @ask.logs
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
end
