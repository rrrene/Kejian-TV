# -*- encoding : utf-8 -*-
class TeachersController < ApplicationController
  def index
    @seo[:title] = '全部老师'
  end  
end