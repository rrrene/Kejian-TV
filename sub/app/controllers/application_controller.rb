# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    # sign_in User.find('50437108e138234991000001')
    # puts request.env['HTTP_USER_AGENT']+request.ip
    # puts ' '
    # puts request.path
    # text = 
    # render text:text and return
    # p request.request_method
    # p request.path
    # p params
  }
  if $psvr_really_production
    rescue_from Exception, with: :render_500
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
  end
  def from_domestic_ips?
    @from_domestic = domestic_blocks.any? { |block| block.include?(request.remote_ip) } if @from_domestic.nil?
    @from_domestic 
  end
  def domestic_blocks
     File.open("#{Rails.root}/lib/domestic.txt").read.split("\n").map { |subnet| attr=subnet.split(/\s/);IPAddr.new(attr[1]).mask(attr[2]) }
  end
  def render_401(exception=nil)
    redirect_to root_path,:alert => '对不起，权限不足！'
    return false
  end
  def render_404(exception=nil)
    @not_found_path = exception ? exception.message : ''
    respond_to do |format|
      format.html { render file: "#{Rails.root}/simple/404.html", layout: false, status: 404 }
      format.all { render nothing: true, status: 404 }
    end
    return false
  end
  def render_500(exception=nil)
    @not_found_path = exception ? exception.message : ''
    if e = exception
      str = "#{Time.now.getlocal}\n"
      str += "#{request.request_method} #{request.path} #{request.ip}\n"
      str += "#{request.user_agent}\n"
      str += e.message+"\n"+e.backtrace.join("\n")
      str += "\n---------------------------------------------\n"
      $debug_logger.fatal(str)
      ExceptionNotifier::Notifier.exception_notification(request.env, exception,
        :data => {:current_user=>current_user}).deliver
    end
    respond_to do |format|
      format.html { render file: "#{Rails.root}/simple/500.html", layout: false, status: 500 }
      format.all { render nothing: true, status: 500 }
    end
    return false
  end
  layout :layout_by_resource
  def layout_by_resource
    if devise_controller?
      "application_for_devise"
    elsif request.path.starts_with?('/embed/')
      "embedded"
    else
      "application"
    end
  end
  
  before_filter :set_vars
  before_filter :xookie
  
  def set_vars
    @seo = Hash.new('')
    if agent = request.env['HTTP_USER_AGENT']
        agent = agent.downcase
        @is_bot = (agent.match(/\(.*https?:\/\/.*\)/)!=nil)
        @is_mac = (agent.index('macintosh')!=nil)
        @is_windows = (agent.index('windows')!=nil)
        @is_firefox = (agent.index('firefox')!=nil)
        @is_chrome = (agent.index('chrome')!=nil)
        @is_ie = (agent.index('msie')!=nil)
        @is_WebKit = (agent.index('webkit')!=nil)
        @is_ie6 = (agent.index('msie 6')!=nil)
        @is_ie7 = (agent.index('msie 7')!=nil)
        @is_ie8 = (agent.index('msie 8')!=nil)
        @is_ie9 = (agent.index('msie 9')!=nil)
        @is_ie10 = (agent.index('msie 10')!=nil)
        @is_mobile = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(request.user_agent =~ /Mobile|webOS/)
    end
  end
  def xookie
    h_xookie = {
      psvr_original_response: true,
      url:"http://#{Setting.ktv_subdomain}/simple/touch.php",
      type:'POST',
      'COOKIE'=>request.env['HTTP_COOKIE'],
      :accept=>'raw'+Setting.dz_authkey,
      psvr_response_anyway: true
    }
    h_xookie[:data] = {:psvr_payloads => @psvr_payloads.to_json} if @psvr_payloads.present?
    res_xookie = nil
    retry_times = 0
    while res_xookie.nil? and retry_times<=3
      retry_times += 1
      res_xookie = Ktv::JQuery.ajax(h_xookie)
    end
    res_xookie.cookies.each do |key,value|
      if !@dz_cookiepre_mid and key =~ /#{Setting.dz_cookiepre}([^_]+)_/
        @dz_cookiepre_mid = $1
      end
      val = CGI::unescape value
      cookies[key]=val
    end
    @_G = MultiJson.load(res_xookie.to_s)
    @_G['uid'] = @_G['uid'].to_i
    @authkey = @_G['authkey']
    @formhash = @_G['formhash']
    if @_G['uid'] != (current_user ? current_user.uid : 0)
      p @_G['uid']
      p (current_user ? current_user.uid : 0)
      sign_out;sign_out_others

      return false
    end
  end

  def rand_sid(len)
    @hash = ''
    @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
    @max = @chars.length - 1
    for i in 0...len
      @hash += @chars[Random.rand(@max)]
    end
    return @hash
  end
  
  def create_session_for_dz(sid)
    ip = request.ip.split('.')
    lastactivity = Time.now.to_i
    if !current_user.nil?
      invisible = PreCommonMemberStatus.where(:uid => current_user.uid).first.invisible==0 ? false : true
      user_forsession = PreCommonMember.where(:uid => current_user.uid).first
      username = user_forsession.username
      groupid = user_forsession.groupid
      non_exist_user = PreCommonSession.where(:username => username).first.nil? ? true : false
      if non_exist_user
        uid = current_user.uid
        PreCommonSession.create(uid:uid,sid:sid,username:username,lastactivity:lastactivity,ip1:ip[0],ip2:ip[1],ip3:ip[2],ip4:ip[3],action:2,groupid:groupid)
      end
    else
      uid = 0
      username = ''
      PreCommonSession.create(uid:uid,sid:sid,username:username,lastactivity:lastactivity,ip1:ip[0],ip2:ip[1],ip3:ip[2],ip4:ip[3],action:2,groupid:7)
    end
  end
  
  before_filter :request_referer
  def request_referer
      if false and !request.referer.nil? and !URI(request.url).path.include?('coursewares') and !@is_bot
          if current_user.nil?
              cuid = nil
          else
              cuid = current_user.id
          end
          CwEvent.add_come_event('Courseware','App',request.ip,request.url,cuid,request.referer,@is_mobile)
          session[:referer] = request.referer
      end
  end
    
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
    if !title.nil? && title.length > 0
      @seo[:title] = "#{title}"
    end
    @seo[:keywords] = keywords
    @seo[:description] = description
  end

  def pagination_get_ready
    params[:page] ||= '1'
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
  end
  def pagination_over(sumcount)
    @page_count = (sumcount*1.0 / @per_page).ceil
  end
  
  
  def user_logged_in_required
    @seo[:title] = '请获取邀请以注册'
    @application_ie_user_logged_in_required = true
    render 'user_logged_in_required',:layout => 'application_ie'
  end
  def modern_required
    @seo[:title] = '请使用更高版本的浏览器'
    render 'modern_required',:layout => 'application_ie'
  end
  def after_sign_in_path_for(resource_or_scope)
    if params[:redirect_to].blank?
      super(resource_or_scope)
    else
      params[:redirect_to]
    end
  end
  def sign_in_others
    # VERY IMPORTANT:
    #   must sign in DZ at this point.
    res = Ktv::JQuery.ajax({
      psvr_original_response: true,
      url:"http://#{Setting.ktv_subdomain}/simple/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1",
      type:'POST',
      data:{
        :fastloginfield => 'username',
        :handlekey => 'ls',
        :password => 'needless_to_say',
        :quickforward => 'yes',
        :username => current_user.slug,
        :psvr_uid => current_user.uid.to_s,
        :psvr_email => current_user.email,
      },
      'COOKIE'=>request.env['HTTP_COOKIE'],
      :accept=>'raw'+Setting.dz_authkey,
      psvr_response_anyway: true
    })
    # p 'gonna set------------------'
    # p res
    # p 'gonna set------------------'
    res.cookies.each do |key,value|
      cookies[key]=CGI::unescape value
    end
    # todo:
    #   upon observing this
    #   the sub-site should login the corresponding user
  end
   
  def sign_out_others
    # VERY IMPORTANT:
    #   must sign out DZ at this point.
    clear_dz!
    # todo:
    #   upon observing this
    #   the sub-site should self-destruct its cookies
  end
  def clear_dz!
    cookies.each do |k,v|
      if k.starts_with? Setting.dz_cookiepre
        cookies.delete k
      end
    end
  end
  
  
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
  
  def bson_invalid_object_id(e)
    raise 'todo'
    # redirect_to root_path, alert: "Resource not found."
  end

  def json_parse_error(e)
    raise 'todo'
    # redirect_to root_path, alert: "Json not valid"
  end

  def mongoid_errors_invalid_type(e)
    raise 'todo'
    # redirect_to root_path, alert: "Json values is not an array"
  end
  def render_optional_error_file(status_code)
    @render_no_sidebar = true
    status = status_code.to_s
    @raw_raw_raw = true
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status}.html.erb", :status => status, :layout => "application"
    else
      render :template => "/errors/unknown.html.erb", :status => status, :layout => "application"
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  NO_REDIRECT_REQUEST_PATHs = [
    '/register05',
    '/register05',
    '/register05_force_relogin',
    '/logout',
    "/account/sign_in",
    '/ajax/renren_huanyizhang',
    '/ajax/renren_real_bind',
    '/ajax/current_user_reg_extent',
    '/ajax/renren_invite',
    '/ajax/register_huanyihuan',
    '/welcome/inactive_sign_up',
    '/account/confirmation/new',
  ]
  before_filter :unknown_user_check,:if=>'current_user'
  def unknown_user_check
    if !current_user.reg_extent_okay?
      unless ApplicationController::NO_REDIRECT_REQUEST_PATHs.include?(request.path) or request.path =~ /follow/
        redirect_to "/register05"
        return false
      end
    else
      unknowns = []
      unknowns << '真实姓名' if current_user.name_unknown
      unknowns << '邮箱地址' if current_user.email_unknown
      #unknowns << '密码' if current_user.encrypted_password.blank?
      unless unknowns.blank?
        flash[:insuf_info] = "请<a href=\"#{edit_user_registration_path}\">点击这里</a>补充您的#{unknowns.join '和'}".html_safe 
      else
        flash[:insuf_info] = nil
      end
      if current_user.unconfirmed_email.present?
        flash[:insuf_info] = "请点击邮箱#{current_user.unconfirmed_email}内的确认链接以完成邮箱修改".html_safe 
      elsif !current_user.email_unknown and !current_user.confirmed?
        flash[:insuf_info] = "请查收邮箱#{current_user.email}内的激活邮件. [<a href=\"/account/confirmation/new\">重发激活邮件</a>]".html_safe 
      end
    end
  end

  
  def require_admin
    if current_user.blank?
      #@simple_cpanel_layout=true
      #render "cpanel/users/login"
      render file:"#{Rails.root}/public/999.html",layout:false
      return
    end
    if ![User::SUP_ADMIN,User::SUB_ADMIN].include?current_user.admin_type
      #@simple_cpanel_layout=true
      #render "cpanel/users/login"
      render file:"#{Rails.root}/public/999.html",layout:false
      return
    end
  end
  
  def require_user(options = {})
    return true if user_signed_in?
    format = options[:format] || :html
    format = format.to_s
    if params[:redirect_path] and params[:redirect_path]!=''
      redirect_path = params[:redirect_path]
    else
      redirect_path = request.path
    end
    login_url = "/login?redirect_to=#{redirect_path}"
    if format == "html"
      redirect_to login_url
      return false
    elsif format == "json"
      if current_user.blank?
        render :json => { :success => false, :msg => "你还没有登录。" },:status => 401
        return false
      end
    elsif format == "text"
      # Ajax 调用的时候如果没有登录，那直接返回 nologin，前段自动处理
      if current_user.blank?
        render :text => "_nologin_",:status => 401 
        return false
      end
    elsif format == "js"
      if current_user.blank?
        render :js => "window.location.href = '#{login_url}';",:status => 401
        return false
      end
    end
    true
  end

  def require_user_json
    require_user(:format => :json)
  end

  def require_user_js
    require_user(:format => :js)
  end

  def require_user_text
    require_user(:format => :text)
  end
  
  def tag_options(options, escape = true)
    unless options.blank?
      attrs = []
      options.each_pair do |key, value|
        if BOOLEAN_ATTRIBUTES.include?(key)
          attrs << %(#{key}="#{key}") if value
        elsif !value.nil?
          final_value = value.is_a?(Array) ? value.join(" ") : value
          final_value = html_escape(final_value) if escape
          attrs << %(#{key}="#{final_value}")
        end
      end
      " #{attrs.sort * ' '}".html_safe unless attrs.empty?
    end
  end
  
  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
  end
  
  def simple_format(text, html_options={}, options={})
    text = ''.html_safe if text.nil?
    start_tag = tag('p', html_options, true)
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "</p><br />#{start_tag}")  # 2+ newline  -> paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.insert 0, start_tag
    text.html_safe.safe_concat("</p>")
  end
  def redirect_sa_cal(url)
    return Digest::MD5.hexdigest(Base64.encode64('liber.'+url))[2..20]
  end
protected
  def bind_renren_prepare!
    rr = Ktv::Renren.new
    @origURL, @domain, @key_id, @captcha_type, @captcha = rr.build_login_page
    @renren_cookie = rr.agent.cookies.join('; ')
    # to be fiiled: :uniqueTimestamp, :email, :icode, :password
  end
  def bind_spetial_ibeike_prepare!
    # todo了啦！
  end
end

