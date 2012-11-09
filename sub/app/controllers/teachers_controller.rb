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
