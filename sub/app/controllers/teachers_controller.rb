# -*- encoding : utf-8 -*-
class TeachersController < ApplicationController
  before_filter :require_user,:only=>[:create,:new,:update,:edit,:destroy]
  before_filter :require_user_js,:only => [:follow,:unfollow]
  before_filter :init_teacher, :only=>[:show,:follow,:unfollow,:followers,:zm_follow,:zm_unfollow,:courses]
  before_filter :auth_user,:only => [:zm_unfollow,:zm_follow]
  def auth_user
    if current_user.blank?
      redirect_to '/',:status => 401
      return false
    end
  end
  def index
    @seo[:title] = '全部老师'
  end  
  def zm_follow
    current_user.follow_teacher(@teacher)
    render json:true
  end
  def zm_unfollow
    current_user.unfollow_teacher(@teacher)
    render json:true
  end

  def follow
    current_user.follow_teacher(@teacher)
    render :text => "1"
  end
  def unfollow
    current_user.unfollow_teacher(@teacher)
    render :text => "1"
  end

  def show
    set_seo_meta(@teacher.name)
  end
  def init_teacher
    @teacher = Teacher.where(name:params[:id]).first
    @teacher ||= Teacher.where(_id:params[:id]).first
    if @teacher.blank?
      render_404
    end
  end
  def followers
    @per_page = 20
    @followers = @teacher.follower_ids.reverse
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("关注#{@teacher.name}的人")
    if params[:format] == "js"
      render "followers.js"
    end
  end
  def courses
    @course = true
      @per_page = 20
      @followers = Course.where(teachers:@teacher.name).paginate(:page => params[:page], :per_page => @per_page)

      @seo[:title] = '#{@teacher.name}的课程'
      if params[:format] == "js"
        render "followers.js"
      else
        render "followers"
      end
  end
  def index
    render text:'deprecated.',status:405    
    @seo[:title] = '全部老师'
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

end
