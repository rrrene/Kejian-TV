# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    puts request.env['HTTP_USER_AGENT']+request.ip
    puts ' '
    puts request.path
    # text = request.user_agent    
    # render text:text and return
  }
  unless $psvr_really_development
    rescue_from Exception, with: :render_500
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
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
  before_filter :xookie,:unless=>'devise_controller?'
  before_filter :dz_security
  
  def set_vars
    @seo = Hash.new('')
    agent = request.env['HTTP_USER_AGENT'].downcase
    @is_bot = (agent.match(/\(.*https?:\/\/.*\)/)!=nil)
    @is_ie = (agent.index('msie')!=nil)
    @is_WebKit = (agent.index('webkit')!=nil)
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
    if !user_signed_in? and dz_auth.present?
      # me off, dz on
      if u = User.authenticate_through_dz_auth!(request,dz_auth,dz_saltkey)
        sign_in(u)
        return true
      end
    elsif user_signed_in? and dz_auth.blank?
      # me on, dz off
      flash[:extra_ucenter_operations] = UCenter::User.synlogin(request,{uid:current_user.uid,psvr_uc_simpleappid:Setting.uc_simpleappid})
    else
      # me off, dz off
      # me on, dz on
      # both nothing to do:)
      return true
    end
  end

  # before_filter :insert_UserOrGuest

  def rand_sid(len)
    @hash = ''
    @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
    @max = @chars.length - 1
    for i in 0...len
      @hash += @chars[Random.rand(@max)]
    end
    return @hash
  end
  
  def insert_UserOrGuest
    if cookies[Discuz.cookiepre_real+'lastvisit'].blank? 
      cookies[Discuz.cookiepre_real+'lastvisit'] = { :value => Time.now.to_i - 3600,:expires => Time.now + 86400*30,:domain => $psvr_really_development ?  ".#{Setting.ktv_sub}.kejian.lvh.me" : ".#{Setting.ktv_sub}.kejian.tv"}
    else
      @lastvisit = cookies[Discuz.cookiepre_real+'lastvisit']     
    end
    
    sid = cookies[Discuz.cookiepre_real+'sid']
    sid_inst = sid.present? ? PreCommonSession.where(sid:sid).first : nil
    if sid.blank? or sid_inst.nil?
      cookies[Discuz.cookiepre_real+'sid'] = {:value  => rand_sid(6),:expires => Time.now + 86400 ,:domain => $psvr_really_development ?  ".#{Setting.ktv_sub}.kejian.lvh.me" : ".#{Setting.ktv_sub}.kejian.tv"}
      @sid = cookies[Discuz.cookiepre_real+'sid']
      create_session_for_dz(@sid)
    else
      @sid = cookies[Discuz.cookiepre_real+'sid']
      PreCommonSession.delete_all("sid=\'#{@sid}\' OR lastactivity<#{Time.now.to_i} OR (uid=\'0\' AND ip1=\'::1\' AND ip2=\'\' AND ip3=\'\' AND ip4=\'\' AND lastactivity>#{Time.now.to_i+840})")
      create_session_for_dz(@sid)
    end
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

  def dz_security
    @authkey = UCenter::Php.md5("#{Setting.dz_authkey}#{cookies[Discuz.cookiepre_real+'saltkey']}")
    if user_signed_in?
      @formhash = Discuz::Utils.formhash({'username'=>current_user.slug,'uid'=>current_user.uid,'authkey'=>@authkey})
    else
      @formhash = Discuz::Utils.formhash({'username'=>'','uid'=>0,'authkey'=>@authkey})
    end
  end
  
  before_filter :get_extcredits
  before_filter :get_srchhotkeywords
  def get_srchhotkeywords
    @s_keyword  = PreCommonSetting.where(:skey => 'srchhotkeywords').first.svalue
    @hotkeywords_list = @s_keyword.split.compact
  end
  def get_extcredits
    if !current_user.nil?
      @cur_newprompt_llb = PreCommonMember.where(:uid => current_user.uid).first.newprompt
      @cur_newpm_llb = UcNewpm.where(:uid => current_user.uid).count
      
      @c_setting  = PreCommonSetting.where(:skey => 'extcredits').first.svalue
      php = PHP.unserialize(@c_setting)
      @extcredit_name = []
      @extcredit_name_list = ''
      php.values.each do |p|
        obj = p['title']
        if !obj.blank?
          @extcredit_name << obj
        end
      end
      @extcredit_name.each_with_index do |ext,index|#1|威望|,2|金钱|,3|贡献|
        @extcredit_name_list += (index+1).to_s + '|' + ext + '|,'
      end
      @extcredit_name_list = @extcredit_name_list.chop  
    end
  end
   
  before_filter :check_privilige
  def check_privilige
    if false and !current_user.nil? and current_user.uid.present?
      @cur_user = PreCommonMember.where(:uid => current_user.uid).first
      @cur_groupid = @cur_user.groupid
      @cur_adminid = @cur_user.adminid
      @cur_newprompt = @cur_user.newprompt
      @cur_allowadmincp = @cur_user.allowadmincp 
      @cur_credits = @cur_user.credits
      @cur_newpm = @cur_user.newpm
      @cur_group = PreCommonUsergroup.where(:groupid => @cur_groupid).first
      @cur_radminid = @cur_group.radminid
     
      @cur_grouptitle = @cur_group.grouptitle
      
      if @cur_radminid > 1
        @fid = PreForumModerator.where(:uid => current_user.uid).first
      end
      #@cur_allowmanage need judge nil?
      @cur_allowmanage = PreCommonBlockPermission.where(:uid => current_user.uid).first 
      if !@cur_adminid.nil?
        @cur_admingroup = PreCommonAdmingroup.where(:admingid => @cur_adminid).first
        if !@cur_admingroup.nil?
          @cur_allowdiy = @cur_admingroup.allowdiy
          @cur_allowmanagearticle = @cur_admingroup.allowmanagearticle
      end
      end
      if !@cur_groupid.nil?
        @cur_allowpostarticle = PreCommonUsergroupField.where(:groupid => @cur_groupid).first
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
    keywords = options[:keywords] || "#{Setting.ktv_subname},#{Setting.ktv_sub},课件,讲义,作业,习题解答,往年试卷,课堂录像,复习资料,课件交流系统"
    description = options[:description] || "#{Setting.ktv_subname}课件交流系统"
    if !title.nil? && title.length > 0
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
    # todo:
    #   upon observing this
    #   the sub-site should login the corresponding user
  end
  def sign_out_others
    # todo:
    #   upon observing this
    #   the sub-site should self-destruct its cookies
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
  before_filter :unknown_user_check
  def unknown_user_check
    if current_user
      unknowns = []
      unknowns << '真实姓名' if current_user.name_unknown
      unknowns << '邮箱地址' if current_user.email_unknown
      #unknowns << '密码' if current_user.encrypted_password.blank?
      unless unknowns.blank?
        flash[:insuf_info] = "请<a href=\"#{edit_user_registration_path}\">点击这里</a>补充您的#{unknowns.join '和'}".html_safe 
      else
        flash[:insuf_info] = nil
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
        render :json => { :success => false, :msg => "你还没有登录。" }
        return false
      end
    elsif format == "text"
      # Ajax 调用的时候如果没有登录，那直接返回 nologin，前段自动处理
      if current_user.blank?
        render :text => "_nologin_" 
        return false
      end
    elsif format == "js"
      if current_user.blank?
        render :js => "window.location.href = '#{login_url}';"
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

end

