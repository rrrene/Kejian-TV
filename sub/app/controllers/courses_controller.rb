# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  def index
    @seo[:title]="全部课程"
    @per_page = 100
    @departments = Department.asc('created_at')
  end

  def show
  end
end
