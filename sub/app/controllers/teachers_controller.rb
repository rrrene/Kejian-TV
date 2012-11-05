# -*- encoding : utf-8 -*-
class TeachersController < ApplicationController
  before_filter :init_teacher, :only=>[:show,:follow,:unfollow]
  def index
    @seo[:title] = '全部老师'
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
    pagination_get_ready
    @coursewares = @teacher.coursewares.normal_father.desc(:created_at)
    pagination_over(@coursewares.count)
    @coursewares = @coursewares.paginate(:page => @page, :per_page => @per_page)
    set_seo_meta(@teacher.name)
  end
  def init_teacher
    @teacher = Teacher.where(name:params[:id]).first
    @teacher ||= Teacher.where(_id:params[:id]).first
    if @teacher.blank?
      render_404
    end
  end

end
