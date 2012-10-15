# -*- encoding : utf-8 -*-
class TeachersController < ApplicationController
  before_filter :init_teacher, :only=>[:show]
  def index
    @seo[:title] = '全部老师'
  end  

  def show
    pagination_get_ready    
    @coursewares = @teacher.coursewares.normal_father.order('id desc')
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
