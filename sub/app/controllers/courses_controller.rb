# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  ADMIN_ACTIONS=[:admin_login,:admin_loginpost,:admin_logout,:admin7,:admin8,:admin9,:admin10,:admin11,:admin12,:admin13,:admin14,:admin15,:admin16,:admin17,:admin18]
  before_filter :require_user,:only=>[:create,:new,:update,:edit,:destroy]+ADMIN_ACTIONS
  before_filter :require_user_js,:only => [:follow,:unfollow]
  before_filter :find_item,:only => [:show,:follow,:unfollow,:syllabus,:asks,:experts]+ADMIN_ACTIONS
  
  def index
    @seo[:title]='课程导航'
    @courses = Course
    @courses = @courses.where(:years=>params[:years].to_i) if params[:years].present?
    @courses = @courses.desc('coursewares_count')
    params[:per_page]||='100'
    @courses = @courses.paginate(:page => params[:page], :per_page => params[:per_page])
    @courses_now_count = Course.where(:years=>20122).count
  end
  def follow
    current_user.follow_course(@course)
    render :text => "1"
  end
  def unfollow
    current_user.unfollow_course(@course)
    render :text => "1"
  end

  def show
    @coursewares = @course.coursewares
    # render :layout=>false
  end
  def admin_login
    @res,@dz_parser,@wp = dz_get("forum.php?mod=modcp&fid=#{@course.fid}")
    if admin_login_form_check!
      @render_overwrite = "admin13"
    end
    render 'show'
  end
  def admin_loginpost
    @res,@dz_parser,@wp = dz_post("forum.php?mod=modcp&action=login",{
      fid:params[:id],
      submit:'yes',
      login_panel:'yes',
      cppwd:params[:cppwd],
      submit:'true'
    })
    if RestClient::Found==@res.class
      session[:psvr_modcp_open] = true
      redirect_to "/courses/#{@course.fid}/admin13"
      return false
    elsif !admin_login_form_check!('密码错误。如果密码输入错误超过 5 次，管理面板将会锁定 15 分钟。')
      render 'show'
    else
      raise Ktv::Shared::ScriptNeedImprovement,"DZ Logic Change?"
    end
  end
  def admin7
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin8
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin9
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin10
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin11
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin12
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin13
    @res,@dz_parser,@wp = dz_get("forum.php?mod=modcp&action=thread&op=thread&fid=#{@course.fid}")
    if admin_login_form_check!('首次进入管理面板或空闲时间过长, 您输入密码才能进入')
      # nothing to do
    end
    render 'show'
  end
  def admin14
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin15
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin16
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin17
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end
  def admin18
    redirect_to "/courses/#{@course.fid}/admin13",notice:'开发中，请先使用资源管理'
  end

  def admin_logout
    @res,@dz_parser,@wp = dz_get("forum.php?mod=modcp&action=logout")
    session[:psvr_modcp_open] = false
    redirect_to "/courses/#{@course.fid}"
  end
  def syllabus
    render 'show'
  end
  def asks
    render 'show'    
  end
  def experts
    render 'show'
  end

  def create
    render text:'deprecated.',status:405    
  end
  def new
    render text:'deprecated.',status:405    
  end
  def update
    render text:'deprecated.',status:405    
  end
  def edit
    render text:'deprecated.',status:405    
  end
  def destroy
    render text:'deprecated.',status:405    
  end

protected
  def find_item
    @course = Course.where(:fid => params[:id].to_i).first
    @course ||= Course.where(:_id => params[:id]).first
    if @course.nil?
      render_404
      return false
    end
    @seo[:title]=@course.name
  end
  def admin_login_form_check!(alertarg=nil)
    if @form=@dz_parser.css('form[action="forum.php?mod=modcp&action=login"]').first
      session[:psvr_modcp_open] = false
      flash[:alert]=alertarg if alertarg
      @render_overwrite = 'admin_login'
    else
      session[:psvr_modcp_open] = true
    end
    return session[:psvr_modcp_open]
  end
end
