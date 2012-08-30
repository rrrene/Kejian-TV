# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    #text = cookies.to_a
    #render text:text and return
  }
  $cnu_new = Time.new(2012,9,3)
  $cnu_exam = Time.new(2013,1,7)
  $cnu_over = Time.new(2013,1,19)
  $cnu_fotos = %w{
    阳光明媚的校本部校门
    乌云密布的北一区校门
    某次零九级新老生交流会
    良乡校区图书馆外
    北一区体育馆的二楼乒乓球室
    教二楼讨论班小教室
    丁浩刚老师在基础物理课上
    教二楼一楼阶梯教室的讲台
    某次学生会手工厨艺DIY
    在北一区文科楼的大阶梯教室上心理学与生活课
    数学科学学院张利友教授的板书
    王志老师在教四楼上大学英语课
    张英伯老师在教二楼上代数课
    刘春晓老师在等待上课铃响
  }
  before_filter :set_vars
  before_filter :xookie,:unless=>'devise_controller?'

  def set_vars
    @seo = Hash.new('')
    agent = request.env['HTTP_USER_AGENT'].downcase
    @is_bot = (agent.match(/\(.*https?:\/\/.*\)/)!=nil)
    @is_ie = (agent.index('msie')!=nil)
    @is_ie6 = (agent.index('msie 6')!=nil)
    @is_ie7 = (agent.index('msie 7')!=nil)
    @is_ie8 = (agent.index('msie 8')!=nil)
    @is_ie9 = (agent.index('msie 9')!=nil)
    @is_ie10 = (agent.index('msie 10')!=nil)
    @bg_index = rand($cnu_fotos.count)
  end
  def xookie
    dz_auth = cookies[Discuz.cookiepre_real+'auth']
    dz_saltkey = cookies[Discuz.cookiepre_real+'saltkey']
    if current_user.nil? and dz_auth.present?
      u = User.authenticate_through_dz_auth!(request,dz_auth,dz_saltkey)
      if u
        sign_in(u)
      end
    end
  end

  #==
  def suggest
    if current_user and !(current_user.followed_topic_ids.blank? and current_user.following_ids.blank?)
      elim = current_user.is_expert ? 3 : 2
      ulim = current_user.is_expert ? 0 : 1
      tlim = 2
      e,u,t = UserSuggestItem.find_by_user(current_user)
      @suggested_experts = e.blank? ? [] :  User.any_in(:_id=>e.random(elim)).not_in(:_id=>current_user.following_ids)
      @suggested_users = u.blank? ?  [] :  User.any_in(:_id=>u.random(ulim)).not_in(:_id=>current_user.following_ids)
      @suggested_topics = t.blank? ? [] : Topic.any_in(:name=>t.random(tlim))
    end
  end
  def set_seo_meta(title, options = {})
    keywords = options[:keywords] || "首都师范大学,CNU,课件,课件交流系统"
    description = options[:description] || "首都师范大学课件交流系统"
    if title.length > 0
      @seo[:title] = "#{title}"
    end
    @seo[:keywords] = keywords
    @seo[:description] = description
  end

end
