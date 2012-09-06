# -*- encoding : utf-8 -*-
class CoursesController < ApplicationController
  def index
    @seo[:title]='全部课程'
    @departments = Department.asc('created_at')
  end

  def show
  end
end
