class CoursesController < ApplicationController
  def index
    @courses = Course.where(:years=>20122).desc(:coursewares_count)
  end

  def show
  end
end
