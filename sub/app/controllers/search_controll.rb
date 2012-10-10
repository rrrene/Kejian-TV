# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def index
    @seo[:title] = '课件搜索'
  end
  def show
    @seo[:title] = params[:q]
  end
end
