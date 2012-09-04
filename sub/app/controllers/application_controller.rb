# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    #text = cookies.to_a
    #render text:text and return
  }
  unless Rails.env.development?
    rescue_from Exception, with: :render_500
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
  end
  def render_401(exception=nil)
    redirect_to root_path,:alert => '对不起，权限不足！'
  end
  def render_404(exception=nil)
    @not_found_path = exception ? exception.message : ''
    respond_to do |format|
      format.html { render file: "#{Rails.root}/simple/404.html", layout: false, status: 404 }
      format.all { render nothing: true, status: 404 }
    end
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
  end
  before_filter :set_vars
  before_filter :xookie,:unless=>'devise_controller?'
  before_filter :dz_security
  
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

  before_filter :insert_UserOrGuest

  def rand_sid(len)
    @hash = ''
    @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
    @max = @chars.length - 1
    for i in 0..len
      @hash += @chars[Random.rand(@max)]
    end
    return @hash
  end
  def insert_UserOrGuest
    if cookies[Discuz.cookiepre_real+'lastvisit'].blank? 
      cookies[Discuz.cookiepre_real+'lastvisit'] = { :value => Time.now.to_i - 3600,:expires => Time.now + 86400*30}
    else
      @lastvisit = cookies[Discuz.cookiepre_real+'lastvisit']     
    end
    ip = request.ip.split('.')
    if cookies[Discuz.cookiepre_real+'sid'].blank?
      cookies[Discuz.cookiepre_real+'sid'] = {:value  => rand_sid(6),:expires => Time.now + 86400 }
      @sid = cookies[Discuz.cookiepre_real+'sid']
      lastactivity = Time.now.to_i
      if !current_user.nil?
        invisible = PreCommonMemberStatus.where(:uid => current_user.uid).first.invisible==0 ? false : true
        user_forsession = PreCommonMember.where(:uid => current_user.uid).first
        username = user_forsession.username
        groupid = user_forsession.groupid
        uid = current_user.uid
        @pcs = PreCommonSession.new
        @pcs.uid = uid
        @pcs.sid = @sid
        @pcs.username = username
        @pcs.lastactivity = lastactivity
        @pcs.ip1 = ip[0]
        @pcs.ip2 = ip[1] 
        @pcs.ip3 = ip[2]
        @pcs.ip4 = ip[3]
        @pcs.action = 2
        @pcs.groupid = groupid
        @pcs.save!
      else
        uid = 0
        username = ''
        @pcs = PreCommonSession.new
        @pcs.uid = uid
        @pcs.sid = @sid
        @pcs.username = username
        @pcs.lastactivity = lastactivity
        @pcs.ip1 = ip[0]
        @pcs.ip2 = ip[1] 
        @pcs.ip3 = ip[2]
        @pcs.ip4 = ip[3]
        @pcs.action = 2
        @pcs.groupid = 7
        @pcs.save!
      end
    else
      @sid = cookies[Discuz.cookiepre_real+'sid']
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
    @s_keyword  = PreCommonSetting. where(:skey => 'srchhotkeywords').first.svalue
    @hotkeywords_list = @s_keyword.split.compact
  end
  def get_extcredits
    if !current_user.nil?
      @c_setting  = PreCommonSetting. where(:skey => 'extcredits').first.svalue
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
    if !current_user.nil?
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

