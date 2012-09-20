# -*- encoding : utf-8 -*-
class DepartmentsController < ApplicationController
  before_filter :dz_navi_extras
  def dz_navi_extras
    @dz_navi_extras = [
      ['全部课程','/courses']
    ]
  end
  def show
    @department = Department.where(_id:params[:id]).first
    @department ||=Department.where(fid:params[:id].to_i).first
    return render_404 if @department.nil?
    @seo[:title] = @department.name
  end
end