# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def index
    @seo[:title] = '课件搜索'
  end
  def show
    @seo[:title] = params[:q]
    redirect_to '/' if request.path.split('/')[0].ends_with?('lucky')
  end
end
