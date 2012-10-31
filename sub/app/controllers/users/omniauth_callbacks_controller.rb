# -*- encoding : utf-8 -*-
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :prepare_auth
  def renren
    @user.name = @info['name']
    make_it_done!
  end
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  
  # This is solution for existing accout want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end
  
private
  def prepare_auth
    if env["omniauth.auth"].blank?
      failure
      return 
    end
    provider = env["omniauth.auth"]['provider'].to_s
    uid = env["omniauth.auth"]['uid'].to_s
    @auth = UCenter::ThirdPartyAuth.getauth(nil,{uid:uid,provider:provider})
    if @auth
      @user = @auth.user 
    else
      @user ||= User.new
      @auth ||= UcThirdPartyAuth.create! do |x|
        x.provider = provider
        x.uid = uid
      end
    end
    @info = env["omniauth.auth"]['info']
    p env["omniauth.auth"].inspect
    return true
  end
  def make_it_done!
    @user.name_unknown = @user.errors[:name].present?
    @user.regip = request.ip
    @user.save(:validate=>false)
    if @user.uid.blank?
      if @user.email.present?
        info0=UCenter::User.get_user(nil,{email:@user.email})
      else
        info0='0'
      end
      if '0'==info0
        @user.fill_in_unknown_email
        ret = UCenter::User.register(request,{
          username:@user.slug,
          password:'psvr_password_unknown',
          email:@user.email,
          regip:request.ip,
          psvr_force:'1'
        })
        if ret.xi.to_i>0
          @user.uid=ret.xi.to_i
          @user.save(:validate=>false)
        else
          raise '注册UC同步注册错误！！！猿快来看一下！'
        end
      else
        User.import_from_dz!(info0)
      end
    end
    @auth.update_attribute(:uc_uid, @user.uid)
    sign_in_others
    sign_in(@user)
    if @user.reg_extent.try(:>=,100)
      redirect_to(root_path, :notice =>  '谢谢！您已经成功登录。')
    else
      redirect_to "/register05"
      return false
    end
  end
end

