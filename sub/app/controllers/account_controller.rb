# -*- encoding : utf-8 -*-
class AccountController < Devise::RegistrationsController
  prepend_before_filter :authenticate_scope!, :only => [:edit_profile,:update_profile]
  def edit
    common_account_op!
    @seo[:title] = '账号设置'
    render "edit",layout:'application'
  end
  def edit_pref
    common_account_op!
    @seo[:title] = '偏好设置'
    render layout:'application'
  end
  def edit_avatar
    common_account_op!
    @seo[:title] = '修改头像'
    render layout:'application'
  end
  def edit_profile
    common_account_op!
    @seo[:title] = '个人资料'
    render layout:'application'
  end
  
  def update_profile
    @user = current_user
    # 安全覆写™
    if params[:user][:name].present?
      @user.name_unknown = false
      @user.name = params[:user][:name].xi
    end
    @user.tagline = params[:user][:tagline].xi

    if @user.save
      @user.update_consultant!
      redirect_to edit_user_registration_path,:notice => '个人资料修改成功'
    else
      # flash[:alert] = "修改失败：#{@user.errors.full_messages.join(", ")}"
      render "edit_profile",:layout => "application"
    end
  end
  
  def edit_notifications
    common_account_op!
    @seo[:title] = '通知与提醒'
    render layout:'application'
  end
  def edit_banking
    common_account_op!
    @seo[:title] = '帐户与帐单'
    render layout:'application'
  end
  def edit_passwd
    common_account_op!
    @seo[:title] = '邮箱与密码安全'
    render layout:'application'
  end
  def edit_i18n
    common_account_op!
    @seo[:title] = '国际化设置'
    render layout:'application'
  end
  def edit_invite
    common_account_op!
    @seo[:title] = '邀请好友注册'
    render layout:'application'
  end

  def after_inactive_sign_up_path_for(resource)
    welcome_inactive_sign_up_path
  end
  def new
    @seo[:title] = '注册新用户'
    if not Setting.allow_register
      render_404
      return false
    end
    resource = build_resource({})
    respond_with resource do |format|
      format.html{render "new"}
    end
  end
  # POST /resource
  def create
    if not Setting.allow_register
      render_404
      return false
    end
    # todo:安全问题？？    
    build_resource

    resource.during_registration = true
    resource.name_unknown = false
    resource.email_unknown = false
    resource.regip = request.ip
    
    if resource.save
      ret = UCenter::User.register(request,{
        username:resource.slug,
        password:params[:user][:password],
        email:resource.email,
        regip:request.ip,
        psvr_force:'1'
      })
      if ret.xi.to_i>0
        resource.update_attribute(:uid,ret.xi.to_i)
      else
        raise '注册UC同步注册错误！！！猿快来看一下！'
      end
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource do |format|
        format.html{ render "new"}
      end
    end
  end
  def update
    # for safety, please keep this deprecation logic.
    render text:'this method is deprecated!'
    return false
  end
  
  def destroy
    # Todo: 用户自杀功能
    resource.soft_delete
    sign_out_and_redirect("/login")
    set_flash_message :notice, :destroyed
  end
  
  
  def after_inactive_sign_up_path_for(resource)
    welcome_inactive_sign_up_path
  end
private
  def common_account_op!
    @user = current_user    
  end  
=begin
  @user.mail_be_followed = ('on'==params[:user]["mail_be_followed"] ? '1' : '0')
  @user.mail_new_answer = ('on'==params[:user]["mail_new_answer"] ? '1' : '0')
  @user.mail_invite_to_ask = ('on'==params[:user]["mail_invite_to_ask"] ? '1' : '0')
  @user.mail_ask_me = ('on'==params[:user]["mail_ask_me"] ? '1' : '0')
  old_user = User.find_by_slug(params[:user]["slug"])
  if !old_user.blank? and old_user.id != @user.id and !params[:user]["slug"].blank?
    flash[:notice]="修改失败，用户名重复！"
    redirect_to request.referer
    return
  end
  if !params[:user]["avatar"].blank?
    @user.avatar_changed_at=Time.now
  end
  # 安全覆写™
  @user.slug = params[:user][:slug]
  @user.name = params[:user][:name]
  @user.email = params[:user][:email]
  @user.avatar = params[:user][:avatar]
  @user.tagline = params[:user][:tagline]
  @user.location = params[:user][:location]
  @user.website = params[:user][:website]
  @user.bio = params[:user][:bio]      
  if @user.email_changed?
    email_warning = '一封确认邮件已经发至您的新电子邮箱地址，请点击其中的链接确认才可成功更改邮箱。'
  else
    email_warning = ''
  end    
  if params[:user][:password].present?
    @user.during_registration = true
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    pass_warning='您的密码已经成功修改，请用新密码登录'
  else
    pass_warning=''
  end


  flash[:alert] = email_warning if email_warning.present?
  cookies[:spetial] = pass_warning if pass_warning.present?

=end
end
