# -*- encoding : utf-8 -*-
class AccountSessionsController < Devise::SessionsController 
  def new
    @seo[:title]='登录'
    @simple_header=true
    @simple_header_width=625
    @traditional||=params[:traditional].present?
    resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    @login_veryspetial ||= (request.path=~/\/spetial$/)
    if @login_veryspetial
      @seo[:title]="用#{Setting.cooperation_site_name}账号登录"
      key = "spetial_#{Setting.ktv_sub.to_s.split('-')[0]}".to_sym
      if !value=Ktv::Consumers[key]
        render text:'this function is not enabled for this site!'
        return false
      else
        respond_with(resource, serialize_options(resource)) do |format|
          format.html{render "new_old",layout:'application_for_devise'}
        end
      end
    else
      respond_with(resource, serialize_options(resource)) do |format|
        format.html{render "new",layout:'application'}
      end
    end

  end
  def create
    if params[:login_veryspetial]
      begin
        key = "spetial_#{Setting.ktv_sub.to_s.split('-')[0]}".to_sym
        if !value=Ktv::Consumers[key]
          render text:'this function is not enabled for this site!'
          return false
        end
        @login_veryspetial = true
        consumer = value[:klass].new
        u,msg = consumer.act!(params,value)
        if u
          resource = u
          suc_flag = true
        else
          flash[:alert]=msg
        end
      rescue => e
        binding.pry
        render text:"对不起，#{value[:namelong]}网站正处于暂时关闭或维护状态，请尝试其他登录方式"
        return false
      end
    else
      @traditional = true
      email = params[:userEmail]
      passwd = params[:userPassword]
      ret = UCenter::User.login(request,{isuid:2,username:email,password:passwd})
      status = ret['root']['item'][0].to_i
      suc_flag = false
      if status > 0
        u = nil
        u ||= User.where(uid:status).first
        u ||= User.import_from_dz!(UCenter::User.get_user(request,{username:status,isuid:1}))
        if u
          resource = u
          suc_flag = true
        end
      elsif -1 == status
        flash[:alert]='无此用户.'
      elsif -2 == status
        flash[:alert]='密码错误.'
      elsif -3 == status
        flash[:alert]='安全提问的回答错误.'
        #todo
      end
    end
    if suc_flag
      sign_in(resource_name, resource);sign_in_others('on'==params[:userKeepLogin])
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      respond_with resource, :location => (params[:redirect_to].present? ? params[:redirect_to] : after_sign_in_path_for(resource))
    else
      new
    end
  end
  def destroy
    sign_out_others
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out
    #synlogout = UCenter::User.synlogout(request)
    #flash[:extra_ucenter_operations] = synlogout.html_safe if synlogout.present?
    
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        head :no_content
      end
    end
  end
end
