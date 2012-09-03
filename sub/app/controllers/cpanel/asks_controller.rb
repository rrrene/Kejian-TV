# -*- encoding : utf-8 -*-
class Cpanel::AsksController < CpanelController
  before_filter :require_ask_admin
  def toggle
    item = SettingItem.find_or_create_by(key:'need_verification')
    if item and item.value=="1"
      item.update_attribute(:value,"0")
    else
      item.update_attribute(:value,"1")
    end
    redirect_to '/cpanel/asks'
  end  
  def index
    @no_form_search=true
    #params[:q] = params[:q].strip if params[:q]
    # @asks = Ask.includes([:user])
    @asks = Ask
    if current_user.admin_type!=User::SUP_ADMIN and !current_user.admin_area.include?("normal_ask")
      @asks = @asks.where(:spams_count.gte => Setting.ask_spam_max)
    end
    if current_user.admin_type!=User::SUP_ADMIN and !current_user.admin_area.include?("spam_ask")
      @asks = @asks.normal
    end
    #@asks = @asks.where(:title=>/(#{params[:q]})/) if params[:q]
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?
      @asks = @asks.any_in(:user_id=>ids)
    elsif !params[:user_name].blank?
      @asks = @asks.any_in(:user_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    if !params[:title].blank?
      @asks = @asks.where(:title=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
    end
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @asks = @asks.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @asks = @asks.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="时间范围不正确！"
    end
    if !params[:answers_count_left].blank?
      @asks = @asks.where(:answers_count.gte=>params[:answers_count_left].to_i)
    end
    if !params[:answers_count_right].blank?
      @asks = @asks.where(:answers_count.lte=>params[:answers_count_right].to_i)
    end
    if !params[:comments_count_left].blank?
      @asks = @asks.where(:comments_count.gte=>params[:comments_count_left].to_i)
    end
    if !params[:comments_count_right].blank?
      @asks = @asks.where(:comments_count.lte=>params[:comments_count_right].to_i)
    end
    if !params[:followed_count_left].blank?
      @asks = @asks.where(:followed_count.gte=>params[:followed_count_left].to_i)
    end
    if !params[:followed_count_right].blank?
      @asks = @asks.where(:followed_count.lte=>params[:followed_count_right].to_i)
    end
    if !params[:views_count_left].blank?
      @asks = @asks.where(:views_count.gte=>params[:views_count_left].to_i)
    end
    if !params[:views_count_right].blank?
      @asks = @asks.where(:views_count.lte=>params[:views_count_right].to_i)
    end
    if params[:spams_count].to_i==1
      @asks = @asks.normal
    elsif params[:spams_count].to_i==2
      @asks = @asks.where(:spams_count.gte => Setting.ask_spam_max)
    end
    if params[:sort_by]=="answers_count"
      @asks = @asks.desc("answers_count")
    elsif params[:sort_by]=="comments_count"
      @asks = @asks.desc("comments_count")
    elsif params[:sort_by]=="followed_count"
      @asks = @asks.desc("followed_count")
    elsif params[:sort_by]=="views_count"
      @asks = @asks.desc("views_count")
    else
      @asks = @asks.desc("created_at")
    end
    @asks = @asks.nondeleted
    @asks = @asks.paginate(:page => params[:page], :per_page => 20)
    

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end
  def verify
    @ask = Deferred.asks.find(params[:id])
    @ask.verify!
    redirect_to '/cpanel/asks_un2'
  end
  def index_un2
    @asks = Deferred.asks.desc("created_at").paginate(:page => params[:page], :per_page => 40) #.includes([:user])
    respond_to do |format|
      format.html
      format.json
    end
  end
  def index_un2all
    Deferred.asks.all.each do |item|
      Resque.enqueue(HookerJob,'Deferred',item.id,:verify!)
    end
    redirect_to '/cpanel/asks_un2', notice:'已经在后台开始全部审核，稍后才能看到结果'
  end

  def index_un

    @asks = Ask.nondeleted.where('this.asks_count==0').desc("created_at").paginate(:page => params[:page], :per_page => 40) #.includes([:user])

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end

  end

  def show
    @ask = Ask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @ask = Ask.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @ask = Ask.find(params[:id])
  end
  
  def create
    @ask = Ask.new(params[:ask])

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @ask = Ask.find(params[:id])
    topics = params[:topics].split(/，|,/)
    topics_del=@ask.topics-topics
    topics_add=topics-@ask.topics
    params[:ask][:body]=params[:content]
    params[:ask][:spams_count]=(params[:ask][:spams_count].to_i>0 ? (params[:ask][:spams_count].to_i):0)
    params[:ask][:views_count]=(params[:ask][:views_count].to_i>0 ? (params[:ask][:views_count].to_i):0)
    params[:ask][:current_user_id] = current_user.id
    respond_to do |format|
      if @ask.update_attributes(params[:ask]) and @ask.update_topics(topics_add,true,current_user.id) and @ask.update_topics(topics_del,false,current_user.id)
        if !@ask.is_normal?
          @ask.redis_search_index_destroy
        else
          @ask.redis_search_index_create
        end
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 更新成功。') }
        format.json
      else
        format.html { redirect_to(edit_cpanel_ask_path, :notice => 'Ask 更新失败！') }
        format.json
      end
    end
  end
  
  def destroy
    if params[:deferred].present?
      Deferred.asks.find(params[:id]).delete
      redirect_to("/cpanel/asks_un2",:notice => "删除成功。")
    else
      @ask = Ask.find(params[:id])
      # AskLog.any_of(target_id:@ask.id,target_ids:@ask.id,target_parent_id:@ask.id).destroy_all
      # @ask.destroy
      @ask.soft_delete(true)
      redirect_to("/cpanel/asks",:notice => "删除成功。")
    end

  end
  
  def deal_asks
    if !params[:choose_asks].blank? and !params[:deal_action].blank?
      asks=Ask.any_in(:_id=>params[:choose_asks])
      if params[:deal_action].to_i==1
        asks.each do |a|
          a.soft_delete(true)
          a.info_delete(current_user.id)
        end
        notice="Asks 处理成功。"
      elsif params[:deal_action].to_i==2
        users=[]
        asks.each do |a|
          users<<a.user_id
        end
        users.uniq.each do |user|
          u=User.where(:_id=>user).first
          if !u.blank?
            u.soft_delete(true)
            u.info_delete(current_user.id)
          end
        end
        notice="Asks 处理成功。"
      end
    else
      notice="Asks 处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(cpanel_asks_path, :notice => notice) }
      format.json
    end
  end
  def require_ask_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and (current_user.admin_area.include?("normal_ask") or current_user.admin_area.include?("spam_ask"))))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
