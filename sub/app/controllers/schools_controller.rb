# -*- encoding : utf-8 -*-
class SchoolsController < ApplicationController
  def index
    @schools = School.all
  end
end
