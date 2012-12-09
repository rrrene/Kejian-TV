# -*- encoding : utf-8 -*-
class DepartmentsController < ApplicationController
  before_filter :require_user,:only=>[:create,:new,:update,:edit,:destroy]
  before_filter :require_user_js,:only => [:follow,:unfollow]
  before_filter :init_department,:only=>[:show,:follow,:unfollow]
  before_filter :dz_navi_extras
  def dz_navi_extras
    @dz_navi_extras = [
      ['课程目录','/courses']
    ]
    false
  end
  def follow
    current_user.follow_department(@department)
    render :text => "1"
  end
  def unfollow
    current_user.unfollow_department(@department)
    render :text => "1"
  end
  def show
    @seo[:title] = @department.name
  end


  def index
    render text:'deprecated.',status:405    
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
  def init_department
    @department = Department.where(_id:params[:id]).first
    @department ||=Department.where(fid:params[:id].to_i).first
    return render_404 if @department.nil?
  end
end
