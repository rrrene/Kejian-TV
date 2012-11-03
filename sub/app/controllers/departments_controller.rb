# -*- encoding : utf-8 -*-
class DepartmentsController < ApplicationController
  before_filter :dz_navi_extras
  before_filter :init_department,:only=>[:show,:follow,:unfollow]
  def dz_navi_extras
    @dz_navi_extras = [
      ['课程目录','/courses']
    ]
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
protected
  def init_department
    @department = Department.where(_id:params[:id]).first
    @department ||=Department.where(fid:params[:id].to_i).first
    return render_404 if @department.nil?
  end
end
