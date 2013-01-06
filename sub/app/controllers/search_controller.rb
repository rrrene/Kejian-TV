# -*- encoding : utf-8 -*-
class SearchController < ApplicationController
  def index
    @seo[:title] = '课件搜索'
    if params[:q].present?
      redirect_to "/search/#{params[:q]}"
      return false
    end
  end
  def lucky
    search_common_op
    @per_page = 1
    @page = 1
    params[:per_page] = '1'
    params[:page] = '1'
    @pages = Page.psvr_search(@page,@per_page,params)
    redirect_to "/coursewares/#{@pages.first.courseware_id}"
    return false
  end
  def show
    search_common_op
    r0 = Time.now
    @ret = Courseware.psvr_redis_search(params[:q],@liber_terms,100)
    @per_page05=@per_page/2
    @ret_residual = @ret.size % @per_page05
    @ret_pages = (@ret.size-@ret_residual)/@per_page05
    @ret_pages += 1 unless 0==@ret_residual
    if @page < @ret_pages
      from=@per_page05*(@page-1)
      size=@per_page05
      @extra_cw = @ret.paginate(per_page:@per_page05,page:@page)
    elsif @page==@ret_pages
      from=@per_page05*(@page-1)
      size=@per_page-@ret_residual
      @extra_cw = @ret.paginate(per_page:@per_page05,page:@page)
    else
      from=@per_page05*(@page-1)+(@ret_residual > 0 ? @per_page-@ret_residual : 0)
      size=@per_page
      @extra_cw = []
    end
    @time_elapsed = ((Time.now - r0) * 1000.0).to_i
    binding.pry
    @coursewares = Courseware.psvr_search(from,size,params,@ret.collect{|x| x['id']})
    @time_elapsed += @coursewares.time
    @quans = 1.upto(@ret.size+@coursewares.total_entries).to_a.paginate(per_page:@per_page,page:@page)
    @quan='个'
    @thing='课件'
    @mode=:kejian
    search_common_over
  end
  def show_contents
    search_common_op
    @pages = Page.psvr_search(@page,@per_page,params)
    @quans=@pages
    @quan='页'
    @thing='课件内容'
    @mode=:kejianneirong
    search_common_over
  end
  def show_playlists
    search_common_op
    @play_lists = PlayList.psvr_search(@page,@per_page,params)
    @quans=@play_lists
    @quan='包'
    @thing='课件锦囊'
    @mode=:bofangliebiao
    search_common_over
  end
  def show_courses
    search_common_op
    q=params[:q]
    r0 = Time.now
    @courses = Redis::Search.query("Course",q,:limit=>500,:sort_field=>'coursewares_count')
    @courses += Redis::Search.complete("Course",q,:limit=>500,:sort_field=>'coursewares_count')
    @courses += Redis::Search.query("Course",@liber_terms,:limit=>500,:sort_field=>'coursewares_count')
    @courses += Redis::Search.complete("Course",@liber_terms,:limit=>500,:sort_field=>'coursewares_count')
    @courses = @courses.psvr_uniq
    @per_page = 100
    @courses = @courses.paginate(:page => @page, :per_page => @per_page)
    @time_elapsed = ((Time.now - r0) * 1000.0).to_i
    @quans=@courses
    @quan='个'
    @thing='课程'
    @mode=:kecheng
    search_common_over
  end
  def show_teachers
    @quans3=true
    search_common_op
    q=params[:q]
    r0 = Time.now
    @teachers = Redis::Search.query("Teacher",q,:limit=>500,:sort_field=>'coursewares_count')
    @teachers += Redis::Search.complete("Teacher",q,:limit=>500,:sort_field=>'coursewares_count')
    @teachers += Redis::Search.query("Teacher",@liber_terms,:limit=>500,:sort_field=>'coursewares_count')
    @teachers += Redis::Search.complete("Teacher",@liber_terms,:limit=>500,:sort_field=>'coursewares_count')
    @teachers = @teachers.psvr_uniq
    @teachers = @teachers.paginate(:page => @page, :per_page => @per_page)
    @time_elapsed = ((Time.now - r0) * 1000.0).to_i
    @quans=@teachers
    @quan='位'
    @thing='老师'
    @mode=:laoshi
    search_common_over
  end
  def show_users
    @quans3=true
    search_common_op
    q=params[:q]
    r0 = Time.now
    @users = Redis::Search.query("User",q,:limit=>500,:sort_field=>'followers_count')
    @users += Redis::Search.complete("User",q,:limit=>500,:sort_field=>'followers_count')
    @users += Redis::Search.query("User",@liber_terms,:limit=>500,:sort_field=>'followers_count')
    @users += Redis::Search.complete("User",@liber_terms,:limit=>500,:sort_field=>'followers_count')
    @users = @users.psvr_uniq
    @users = @users.paginate(:page => @page, :per_page => @per_page)
    @time_elapsed = ((Time.now - r0) * 1000.0).to_i
    @quans=@users
    @quan='位'
    @thing='用户'
    @mode=:yonghu
    search_common_over
  end
private
  def search_common_op
    @user_provided_term=params[:q]
    @using_ajax = request.path.split('/')[1]=='ajax'
    @seo[:title] = params[:q]
    @page = params[:page].to_i
    unless @page > 0
      @page = 1
      params[:page] = @page.to_s
    end
    params[:per_page] ||= cookies[:search_per_page]
    @per_page = params[:per_page].to_i
    unless @per_page > 0
      @per_page = 10 
      params[:per_page] = @per_page.to_s
    end
    if @quans3 and @per_page%3!=0
      @per_page = 15
    elsif !@quans3 and ![10,30,50].include? @per_page
      @per_page = 10
    end
    params[:per_page]=@per_page.to_s
    cookies[:search_per_page] = @per_page.to_s
    params[:q]=params[:q].xi
    q=params[:q]
    @liber_terms = PinyinSplit.split(q.gsub(/[^\w]/,'').downcase)
    @fenci_terms = Redis::Search.split(q).collect{|x| x.force_encoding('utf-8')}
    @elastic_terms = [] 
    @spetial_symbols=q.scan(/[-+#]+/).to_a
  end
  def search_common_over
    p @final_term=(@liber_terms.split(/\s+/)+@fenci_terms+@elastic_terms+@spetial_symbols).uniq
    if !current_user.nil? and current_user.mark_search_keyword
      SearchHistory.add_search_keyword(current_user,params[:q],request.ip,params[:action])      
    end
    respond_to do |format|
      format.html{
        render 'show'
      }
      format.json{
        render json:{
          term:@user_provided_term,
          terms:@final_term,
          content:render_to_string(:file=>"search/_#{params[:action]}.html.erb",:layout=>nil, :formats=>[:html]),
          main:render_to_string(:file=>'search/_search_show_common_main.html.erb',:layout=>nil, :formats=>[:html])
        }
      }
    end
  end
end

