# -*- encoding : utf-8 -*-
class AccountSessionsController < Devise::SessionsController 
  def new
    @seo[:title]='登录'
    @simple_header=true
    @simple_header_width=625
    @traditional||=params[:traditional].present?
    resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource)) do |format|
      format.html{render "new",layout:'application'}
    end
  end
  def create
    email = params[:userEmail]
    passwd = params[:userPassword]
    email ||= params[:user][:email]
    passwd ||= params[:user][:password]
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
    if suc_flag
      sign_in(resource_name, resource);sign_in_others
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      @traditional = true
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
