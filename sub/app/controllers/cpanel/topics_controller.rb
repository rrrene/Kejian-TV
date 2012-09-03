# -*- encoding : utf-8 -*-
class Cpanel::TopicsController < CpanelController
  before_filter :require_topic_admin
  def index
    @no_form_search=true
    #params[:q] = params[:q].strip if params[:q]
    @topics = Topic
    #@topics = @topics.where(:name=>/#{params[:q]}/) if params[:q]
    @topics = @topics.where(:name=>params[:name]) unless params[:name].blank?
    @topics = @topics.where(:tags => params[:tag]) unless params[:tag].blank?
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @topics = @topics.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @topics = @topics.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="时间范围不正确！"
    end
    @topics = @topics.desc(params[:sort]) unless params[:sort].blank?
    @topics = @topics.desc("created_at")
    @topics = @topics.nondeleted
    @topics = @topics.paginate(:page => params[:page], :per_page => 20)
    
    #    @tags = Topic.all.to_a.inject([]){|s,i| if i.tags;s+i.tags;else;[];end}
    #    if @tags
    #      @tags = @tags.uniq
    #    else
    #      @tags = []
    #    end



    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @topic = Topic.find(params[:id])
  end
  
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @topic = Topic.find(params[:id])
    params[:topic][:asks_count]=params[:topic][:asks_count].to_i
    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        if params[:topic][:will_autofollow].to_i!=0 and !@topic.has_autofollow
          Resque.enqueue(HookerJob,'Topic',@topic.id,:check_autofollow)
        end
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 更新成功。') }
        format.json
      else
        format.html { redirect_to(edit_cpanel_topic_path(@topic), :notice => 'Topic 更新失败！') }
        format.json
      end
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    @topic.soft_delete(true)
    
    respond_to do |format|
      format.html { redirect_to(cpanel_topics_path,:notice => "删除成功。") }
      format.json
    end
  end
  def deal_topics
    if !params[:choose_topics].blank?
      topics=Topic.any_in(:_id=>params[:choose_topics])
      topics.each do |t|
        t.soft_delete(true)
      end
      notice="Topics 处理成功。"
    else
      notice="Topics 处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(cpanel_topics_path, :notice => notice) }
      format.json
    end
  end
  
  def require_topic_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("topic")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
