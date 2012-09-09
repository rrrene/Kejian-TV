# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  def index
    @seo[:title]='全部课程'
    @courses = Course.desc('coursewares_count').paginate(:page => params[:page], :per_page => 100)
  end

  def show
  end
end
