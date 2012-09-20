# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  def index
    @seo[:title]='课程目录'
    @courses = Course
    @courses = @courses.where(:years=>params[:years].to_i) if params[:years].present?
    @courses = @courses.desc('coursewares_count')
    @courses = @courses.paginate(:page => params[:page], :per_page => 100)
    @courses_now_count = Course.where(:years=>20122).count
  end

  def show
  end
end
