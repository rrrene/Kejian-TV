# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  def index
    @seo[:title]="本学期课程"
    @per_page = 100
    @courses = Course
    if request.path=='/un_courses'
      @courses = @courses.where(:page.ne=>20122).desc(:coursewares_count)
    else
      @courses = @courses.where(:years=>20122).desc(:coursewares_count)
    end
  end

  def show
  end
end
