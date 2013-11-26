# -*- encoding : utf-8 -*-
class Api::HomeController < ApiController
  def index
    render json:{}
  end
  def doing
    pagination_get_ready
    @asks = Log.all
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
  def search
    pagination_get_ready
    the_limit = 1000
    case params[:type]
    when 'Topic'
    result = Redis::Search.query("Topic",params[:q].strip,:limit => the_limit,:sort_field=>'followers_count')
    when 'User'
    result = Redis::Search.complete("User",params[:q].strip,:limit => the_limit,:sort_field=>'followers_count')
    when 'Ask'
    result = Redis::Search.query("Ask",params[:q].strip,:limit => the_limit,:sort_field=>'answers_count')
    end
    @asks = result
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
end
