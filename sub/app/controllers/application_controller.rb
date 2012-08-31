# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    #text = cookies.to_a
    #render text:text and return
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
    @bg_index = rand(Setting.fotos.count)
  end
  def xookie
    dz_auth = cookies[Discuz.cookiepre_real+'auth']
    dz_saltkey = cookies[Discuz.cookiepre_real+'saltkey']
    if dz_auth.present?
      u = User.authenticate_through_dz_auth!(request,dz_auth,dz_saltkey)
      if u
        sign_in(u)
        return true
      end
    end
    sign_out
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
    keywords = options[:keywords] || "#{Setting.ktv_subname},#{Setting.ktv_sub},课件,讲义,作业,习题解答,往年试卷,课堂录像,复习资料,课件交流系统"
    description = options[:description] || "#{Setting.ktv_subname}课件交流系统"
    if title.length > 0
      @seo[:title] = "#{title}"
    end
    @seo[:keywords] = keywords
    @seo[:description] = description
  end

  def sign_out_others
    cookies.each do |k,v|
      if k.starts_with?(Discuz.cookiepre)
        cookies.delete(k, 'domain' => (Discuz.cookiedomain))
      end
    end
  end
end

