# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def index
    @seo[:title] = '课件搜索'
    if params[:q].present?
      redirect_to "/search/#{params[:q]}"
      return false
    end
  end
  def show
    @seo[:title] = params[:q]
    params[:page]||='1'
    params[:per_page]||='15'
    @bm = Benchmark.measure {
      params_q = params[:q].xi
      @pages = Page.search(:page=> params[:page], :per_page=> params[:per_page]) do
        query do
          string params_q, default_operator: "AND"
        end
      end
    }.total
    redirect_to "/coursewares/#{@pages.first.courseware_id}" if request.path.split('/')[0].ends_with?('lucky')
  end
end
