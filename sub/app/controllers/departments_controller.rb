class DepartmentsController < ApplicationController
  def show
    @department = Department.find(params[:id])
    @seo[:title] = @department.name
  end
end