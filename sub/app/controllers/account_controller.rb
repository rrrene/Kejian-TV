# -*- encoding : utf-8 -*-
class AccountController < Devise::RegistrationsController
  def edit
    @seo[:title] = '账号设置'
    @user = current_user
    render "edit"
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
      ret = UCenter::User.register(nil,{username:resource.slug})
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
    begin
      # 安全覆写™
      if params[:user][:name].present? or params[:user][:email].present?
        resource.name_unknown = false
        resource.email_unknown = false
      end
      resource.mail_be_followed = ('on'==params[resource_name]["mail_be_followed"] ? '1' : '0')
      resource.mail_new_answer = ('on'==params[resource_name]["mail_new_answer"] ? '1' : '0')
      resource.mail_invite_to_ask = ('on'==params[resource_name]["mail_invite_to_ask"] ? '1' : '0')
      resource.mail_ask_me = ('on'==params[resource_name]["mail_ask_me"] ? '1' : '0')
      old_user = User.find_by_slug(params[resource_name]["slug"])
      if !old_user.blank? and old_user.id != resource.id and !params[resource_name]["slug"].blank?
        flash[:notice]="修改失败，用户名重复！"
        redirect_to request.referer
        return
      end
      if !params[resource_name]["avatar"].blank?
        resource.avatar_changed_at=Time.now
      end
      # 安全覆写™
      resource.slug = params[:user][:slug]
      resource.name = params[:user][:name]
      resource.email = params[:user][:email]
      resource.avatar = params[:user][:avatar]
      resource.tagline = params[:user][:tagline]
      resource.location = params[:user][:location]
      resource.website = params[:user][:website]
      resource.bio = params[:user][:bio]      
      if resource.email_changed?
        email_warning = '一封确认邮件已经发至您的新电子邮箱地址，请点击其中的链接确认才可成功更改邮箱。'
      else
        email_warning = ''
      end    
      if params[:user][:password].present?
        resource.during_registration = true
        resource.password = params[:user][:password]
        resource.password_confirmation = params[:user][:password_confirmation]
        pass_warning='您的密码已经成功修改，请用新密码登录'
      else
        pass_warning=''
      end
      if resource.save
        resource.update_consultant!
        flash[:alert] = email_warning if email_warning.present?
        cookies[:spetial] = pass_warning if pass_warning.present?
        redirect_to edit_user_registration_path,:notice => '个人资料修改成功'
      else
        flash[:alert] = "修改失败：#{resource.errors.full_messages.join(", ")}"
        render "edit",:layout => "application_for_devise"
      end
    rescue => e
      puts "#{e}"
      $debug_logger.fatal("#{e}")
      flash[:alert] = "修改失败：#{resource.errors.full_messages.join(", ")}"
      render "edit",:layout => "application_for_devise"
    end
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
  
end
