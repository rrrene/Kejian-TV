# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  ADMIN_ACTIONS=[:admin,:admin7,:admin8,:admin9,:admin10,:admin11,:admin12,:admin13,:admin14,:admin15,:admin16,:admin17,:admin18]
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
  def admin
    res = Ktv::JQuery.ajax({
      psvr_original_response: true,
      url:"http://#{Setting.ktv_subdomain}/simple/forum.php?mod=modcp&fid=#{@course.fid}",
      type:'GET',
      data:{},
      'COOKIE'=>request.env['HTTP_COOKIE'],
      :accept=>'raw'+Setting.dz_authkey,
      psvr_response_anyway: true
    })
    binding.pry
    render 'show'
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
end
