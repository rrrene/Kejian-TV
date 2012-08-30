# coding: UTF-8
class Cpanel::NoticesController < CpanelController
  before_filter :require_notice_admin
  def index
    @no_form_search=true
    @notices = Notice.desc('start_at').paginate(:page => params[:page], :per_page => 30)
    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @notice = Notice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @no_form_search=true
    @action="new"
    @notice = Notice.new
    @notice.created_at=Time.now
    @notice.updated_at=Time.now
    @notice.start_at=Time.now

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @action="edit"
    @notice = Notice.find(params[:id])
  end
  
  def create
    @notice = Notice.new()
    @notice.body=params[:body]
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
    else
      flash[:notice]="生效起始时间格式不正确！"
      redirect_to "/cpanel/notices/new"
      return
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
    else
      flash[:notice]="生效终止时间格式不正确！"
      redirect_to "/cpanel/notices/new"
      return
    end
    if @from_time>@to_time
      flash[:notice]="时间范围不正确！"
      redirect_to "/cpanel/notices/new"
      return
    else
      @notice.start_at=@from_time
      @notice.end_at=@to_time
    end
    if params[:open_notice].to_i==1
      @notice.open=true
    else
      @notice.open=false
    end
    respond_to do |format|
      if @notice.save
        format.html { redirect_to(cpanel_notices_path, :notice => 'Notice 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @notice = Notice.find(params[:id])
    @notice.body=params[:body]
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time=Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash[:notice]="生效起始时间格式不正确！"
      redirect_to edit_cpanel_notice_path(@notice.id)
      return
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash[:notice]="生效终止时间格式不正确！"
      redirect_to edit_cpanel_notice_path(@notice.id)
      return
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash[:notice]="时间范围不正确！"
      redirect_to edit_cpanel_notice_path(@notice.id)
      return
    elsif !@from_time.blank? and !@to_time.blank?
      @notice.start_at=@from_time
      @notice.end_at=@to_time
    end
    if params[:open_notice].to_i==1
      @notice.open=true
    else
      @notice.open=false
    end
    respond_to do |format|
      if @notice.save
        format.html { redirect_to(cpanel_notices_path, :notice => 'Notice 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @notice = Notice.find(params[:id])
    # @notice.delete
    @notice.soft_delete(true)

    respond_to do |format|
      format.html { redirect_to(cpanel_notices_path,:notice => "删除成功。") }
      format.json
    end
  end
  def require_notice_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("notice")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
