# coding: UTF-8
class Cpanel::ReportSpamsController < CpanelController
  before_filter :require_report_admin
  def index
    @no_form_search = true
    @report_spams = ReportSpam.nondeleted
    @report_spams = @report_spams.where(:descriptions=>/^#{params[:user_name]}:/) unless params[:user_name].blank?
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @report_spams = @report_spams.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="举报时间的起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @report_spams = @report_spams.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="举报时间的终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="举报时间的时间范围不正确！"
    end
    if !params[:handler_name].blank? and !(ids=User.where(:name=>params[:handler_name]).map{|x|x.id}).blank?
      @report_spams = @report_spams.any_in(:handler_id=>ids)
    elsif !params[:handler_name].blank?
      @report_spams = @report_spams.any_in(:handler_id=>ids)
      flash.now[:notice]="该处理人不存在！"
    end
    if !params['handle_datepicker_from'].blank? and !params["handle_time_from"].blank?
      @handle_from_time = Time.strptime params['handle_datepicker_from']+' '+params["handle_time_from"],"%Y-%m-%d %H:%M"
      @report_spams = @report_spams.where(:handled_at.gt=>@handle_from_time)
    elsif((!params['handle_datepicker_from'].blank? and params["handle_time_from"].blank?) or (params['handle_datepicker_from'].blank? and !params["handle_time_from"].blank?))
      flash.now[:notice]="处理时间的起始时间格式不正确！"
    end
    if !params['handle_datepicker_to'].blank? and !params["handle_time_to"].blank?
      @handle_to_time = Time.strptime params['handle_datepicker_to']+' '+params["handle_time_to"],"%Y-%m-%d %H:%M"
      @report_spams = @report_spams.where(:handled_at.lt=>@handle_to_time)
    elsif((!params['handle_datepicker_to'].blank? and params["handle_time_to"].blank?) or (params['handle_datepicker_to'].blank? and !params["handle_time_to"].blank?))
      flash.now[:notice]="处理时间的终止时间格式不正确！"
    end
    if !@handle_from_time.blank? and !@handle_to_time.blank? and @handle_from_time>@handle_to_time
      flash.now[:notice]="处理时间的时间范围不正确！"
    end
    if !params[:handled].blank?
      if params[:handled].to_i==1
        @report_spams = @report_spams.where(:handled_text=>nil)
      elsif params[:handled].to_i==2
        @report_spams = @report_spams.where(:handled_text.ne=>nil)
      end
    end
    @report_spams = @report_spams.desc("created_at")
    @report_spams = @report_spams.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @report_spam = ReportSpam.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def destroy
    @report_spam = ReportSpam.find(params[:id])
    # @report_spam.delete
    @report_spam.soft_delete(true)
    respond_to do |format|
      format.html { redirect_to(cpanel_report_spams_path,:notice => "删除成功。") }
      format.json
    end
  end
  def deal_report
    if !params[:handled_result].blank? and !params[:report_id].blank? and !params[:handled_text].blank?
      report=ReportSpam.where(:_id=>params[:report_id]).first
      if !report.blank?
        report.handled_at=Time.now
        report.handler_id=current_user.id
        report.handled_text=params[:handled_result]+","+params[:handled_text]
        if report.save
          notice="处理成功！"
          report.send_mailer
        else
          notice="处理失败！"
        end
      else
        notice="要处理的举报不存在！"
      end
    else
      notice="请选择要处理的举报！"
    end
    respond_to do |format|
      format.html {redirect_to(cpanel_report_spams_path,:notice =>notice)}
      format.json
    end
  end
  def require_report_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("report")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
