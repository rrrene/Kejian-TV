class CoursesController < ApplicationController
  def index
    @seo[:title]="本学期课程"
    @courses = Course.where(:years=>20122).desc(:coursewares_count)
  end

  def show
  end
end
