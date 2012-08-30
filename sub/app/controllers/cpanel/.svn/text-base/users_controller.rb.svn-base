# coding: UTF-8
class Cpanel::UsersController < CpanelController
  before_filter :require_user_admin,:only=>["index","show","new","create","edit","update","edit_admin","update_admin","destroy"]
  before_filter :require_user_admin_ad,:only=>["edit_admin","update_admin"]
  before_filter :require_avatar_admin,:only=>["avatar_admin","avatar_del"]
  
  def index
    @no_form_search=true
    @users = User
    #params[:q] = params[:q].strip if params[:q]
    #@users = @users.any_of({:name=>Regexp.new(params[:q])},{:email=>params[:q]},{:slug=>params[:q]}) if params[:q]
    #@users = @users.where(:tags => params[:tag]) if params[:tag]
    #@users = @users.where(:is_expert=>true) if params[:is_expert]
    if !params[:name].blank?
      @users = @users.where(:name=>params[:name])
    end
    if !params[:email].blank?
      @users = @users.where(:email=>params[:email])
    end
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @users = @users.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="注册时间的起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @users = @users.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="注册时间的终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="注册时间的时间范围不正确！"
    end
    if !params['last_datepicker_from'].blank? and !params["last_time_from"].blank?
      @last_from_time = Time.strptime params['last_datepicker_from']+' '+params["last_time_from"],"%Y-%m-%d %H:%M"
      @users = @users.where(:last_login_at.gt=>@last_from_time)
    elsif((!params['last_datepicker_from'].blank? and params["last_time_from"].blank?) or (params['last_datepicker_from'].blank? and !params["last_time_from"].blank?))
      flash.now[:notice]="最后登录的起始时间格式不正确！"
    end
    if !params['last_datepicker_to'].blank? and !params["last_time_to"].blank?
      @last_to_time = Time.strptime params['last_datepicker_to']+' '+params["last_time_to"],"%Y-%m-%d %H:%M"
      @users = @users.where(:last_login_at.lt=>@last_to_time)
    elsif((!params['last_datepicker_to'].blank? and params["last_time_to"].blank?) or (params['last_datepicker_to'].blank? and !params["last_time_to"].blank?))
      flash.now[:notice]="最后登录的终止时间格式不正确！"
    end
    if !@last_from_time.blank? and !@last_to_time.blank? and @last_from_time>@last_to_time
      flash.now[:notice]="最后登录的时间范围不正确！"
    end
    if !params[:asks_count_left].blank?
      @users = @users.where(:asks_count.gte=>params[:asks_count_left].to_i)
    end
    if !params[:asks_count_right].blank?
      @users = @users.where(:asks_count.lte=>params[:asks_count_right].to_i)
    end
    if !params[:answers_count_left].blank?
      @users = @users.where(:answers_count.gte=>params[:answers_count_left].to_i)
    end
    if !params[:answers_count_right].blank?
      @users = @users.where(:answers_count.lte=>params[:answers_count_right].to_i)
    end
    if !params[:comments_count_left].blank?
      @users = @users.where(:comments_count.gte=>params[:comments_count_left].to_i)
    end
    if !params[:comments_count_right].blank?
      @users = @users.where(:comments_count.lte=>params[:comments_count_right].to_i)
    end
    if !params[:followers_count_left].blank?
      @users = @users.where(:followers_count.gte=>params[:followers_count_left].to_i)
    end
    if !params[:followers_count_right].blank?
      @users = @users.where(:followers_count.lte=>params[:followers_count_right].to_i)
    end
    if !params[:login_times_left].blank?
      @users = @users.where(:login_times.gte=>params[:login_times_left].to_i)
    end
    if !params[:login_times_right].blank?
      @users = @users.where(:login_times.lte=>params[:login_times_right].to_i)
    end
    if params[:user_type].to_i!=0
      @users = @users.where(:user_type=>params[:user_type])
    end
    if params[:admin_type].to_i!=0
      @users = @users.where(:admin_type=>params[:admin_type])
    end
    if params[:sort]=="asks_count"
      @users = @users.desc("asks_count")
    elsif params[:sort]=="answers_count"
      @users = @users.desc("answers_count")
    elsif params[:sort]=="comments_count"
      @users = @users.desc("comments_count")
    elsif params[:sort]=="followers_count"
      @users = @users.desc("followers_count")
    elsif params[:sort]=="views_count"
      @users = @users.desc("views_count")
    elsif params[:sort]=="last_login_at"
      @users = @users.desc("last_login_at")
    elsif params[:sort]=="login_times"
      @users = @users.desc("login_times")
    else
      @users = @users.desc("created_at")
    end
    if(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("user_xml")))  
      @users_xls = @users.limit(200)
    end
    @users = @users.paginate(:page => params[:page], :per_page => 20)
    
    # @tags = User.all.to_a.inject([]){|s,i| if i.tags;s+i.tags;else;[];end}
    # if @tags
    #   @tags = @tags.uniq
    # else
    #   @tags = []
    # end

    respond_to do |format|
      format.html # index.html.erb
      format.json
      format.xls do
        render :xls => @users_xls,
          :columns => [ :name,:tagline,:user_type,:admin_type,:asks_count,:answers_count,:comments_count,:followers_count,:email,:created_at ],
          :headers => %w[ 昵称 一句话介绍 用户组 管理组 提问数 回答数 评论数 被关注数 注册邮箱 注册时间 ]
      end
    end
  end
  
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @user = User.find(params[:id])
  end
  
  def edit_admin
    @no_form_search=true
    @user = User.find(params[:id])
  end
  
  def update_admin
    @user = User.find(params[:id])
    if params[:admins].blank?
      flash[:notice]="尚未设置副管理员权限，请设置！"
      @no_form_search=true
      render :action => "edit_admin"
      return
    end
    @user.admin_type=3
    @user.admin_area=params[:admins]+params[:admins2]
    respond_to do |format|
      if @user.save
        format.html {redirect_to("/cpanel/users/#{@user.id}/edit_admin", :notice => '权限设置成功!')}
        format.json
      else
        flash[:notice]="尚未设置副管理员权限，请设置！"
        @no_form_search=true
        format.html {render :action => "edit_admin"}
        format.json
      end
    end
  end
  
  def avatar_admin
    @no_form_search=true
    @users=User.where(:avatar_filename.ne=>nil).nondeleted
    if !params[:name].blank?
      @users = @users.where(:name=>params[:name])
    end
    @users=@users.desc("avatar_changed_at").paginate(:page => params[:page], :per_page => 30)
  end
  
  def avatar_del
    if !params[:avatars].blank?
      params[:avatars].each do |id|
        u=User.where(:_id=>id).first
        if !u.blank?
          u.update_attribute("avatar_filename",nil)
        end
      end
    end
    redirect_to "/cpanel/user/avatar_admin",:notice=>"删除成功！"
  end
  
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(cpanel_users_path, :notice => 'User 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    old_user = User.find_by_slug(params[:user]["slug"])
    if !old_user.blank? and old_user.id != @user.id
      flash[:notice]="修改失败，个性域名重复！"
      @no_form_search=true
      render :action => "edit"
      return
    end
    if params[:user]["admin_type"].to_i==User::SUB_ADMIN and @user.admin_area.blank?
      flash[:notice]="admin area can not be blank!"
      @no_form_search=true
      render :action => "edit"
      return
    end
    has_done=true
    respond_to do |format|
      #@user.tags_array = params[:user][:tags_array]
      if params[:user][:user_type].to_i==User::EXPERT_USER
        @user.banished="0"
        @user.deleted=0
        @user.is_expert=true
        @user.user_type=User::EXPERT_USER
      elsif params[:user][:user_type].to_i==User::BAN_USER
        has_done=false
      else
        @user.banished="0"
        @user.deleted=0
        @user.is_expert=false
        @user.user_type=params[:user][:user_type].to_i
      end
      if params[:user][:admin_type].to_i!=0# and current_user.admin_type==User::SUP_ADMIN
        @user.admin_type=params[:user][:admin_type].to_i
      end
      @user.is_expert_why=params[:user][:is_expert_why]
      if @user.update_attribute(:name,params[:name]) and @user.update_attributes!(params[:user])
        if !has_done
          @user.soft_delete(true)
          @user.info_delete(current_user.id)
        end
        format.html { redirect_to(cpanel_users_path, :notice => 'User 更新成功。') }
        format.json
      else
        flash[:notice]="修改失败！"
        @no_form_search=true
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.soft_delete(true)

    respond_to do |format|
      format.html { redirect_to(cpanel_users_path,:notice => "删除成功。") }
      format.json
    end
  end
  
  def welcome
    @no_form_search=true
  end
  
  def require_user_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and (current_user.admin_area.include?("user_normal") or current_user.admin_area.include?("user_xml"))))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_user_admin_ad
    if !(current_user.admin_type==User::SUP_ADMIN)
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_avatar_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("user_avatar")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end

