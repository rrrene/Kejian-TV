# -*- encoding : utf-8 -*-
class Cpanel::CommentsController < CpanelController
  before_filter :require_comment_admin
  def verify
    @comment = Deferred.comments.find(params[:id])
    @comment.verify!
    redirect_to '/cpanel/comments_un2'
  end
  def index_un2
    @comments = Deferred.comments.desc("created_at").paginate(:page => params[:page], :per_page => 40) #.includes([:user])
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def index_un2all
    Deferred.comments.all.each do |item|
      Resque.enqueue(HookerJob,'Deferred',item.id,:verify!)
    end
    redirect_to '/cpanel/comments_un2', notice:'已经在后台开始全部审核，稍后才能看到结果'
  end
  def index
    @no_form_search=true
    #params[:q] = params[:q].strip if params[:q]
    @comments = Comment#.includes([:user])
    #@comments = Comment.where(:body=>/#{params[:q]}/) if params[:q]
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?
      @comments = @comments.any_in(:user_id=>ids)
    elsif !params[:user_name].blank?
      @comments = @comments.any_in(:user_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    if !params[:body].blank?
      @comments = @comments.where(:body=>/#{params[:body].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
    end
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @comments = @comments.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @comments = @comments.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="时间范围不正确！"
    end
    @comments = @comments.desc("created_at")
    @comments = @comments.nondeleted
    @comments = @comments.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @comment = Comment.find(params[:id])
  end
  
  def create
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(cpanel_comments_path, :notice => 'Comment 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(cpanel_comments_path, :notice => 'Comment 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    if params[:deferred].present?
      Deferred.comments.find(params[:id]).delete
      redirect_to("/cpanel/comments_un2",:notice => "删除成功。")
    else
      @comment = Comment.find(params[:id])
      # CommentLog.any_of(target_id:@comment.id,target_ids:@comment.id,target_parent_id:@comment.id).destroy_all
      # @comment.destroy
      @comment.soft_delete(true)
      redirect_to("/cpanel/comments",:notice => "删除成功。")
    end
  end
  def deal_comments
    if !params[:choose_comments].blank? and !params[:deal_action].blank?
      comments=Comment.any_in(:_id=>params[:choose_comments])
      if params[:deal_action].to_i==1
        comments.each do |c|
          c.soft_delete(true)
          c.info_delete(current_user.id)
        end
        notice="Comments 处理成功。"
      elsif params[:deal_action].to_i==2
        users=[]
        comments.each do |c|
          users<<c.user_id
        end
        users.uniq.each do |user|
          u=User.where(:_id=>user).first
          if !u.blank?
            u.soft_delete(true)
            u.info_delete(current_user.id)
          end
        end
        notice="Comments 处理成功。"
      end
    else
      notice="Comments 处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(cpanel_comments_path, :notice => notice) }
      format.json
    end
  end
  
  def require_comment_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("comment")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
