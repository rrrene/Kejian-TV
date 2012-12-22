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
    # 好的，所以，如果UCenter找到了这个人，那么@auth 是数组
    @auth = UCenter::ThirdPartyAuth.getauth(nil,{uid:uid,provider:provider,oauth_succeeded:true}).try(:[],'root').try(:[],'item')
    if @auth
      # 那么，在这个点上
      # 如果用户以前从来没有来过这个子站
      # 那么将被创建，用户资料是从uc那边搞到手的
      @user = User.find_by_uid(@auth[0])
    end
    if !@auth or !@user
      @user = User.new
      # 好的，所以，那么如果没找到呢？是个Hash！！！
      @auth = {
        :provider => provider,
        :uid => uid,
      }
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
        info0=UCenter::User.get_user(nil,{username:@user.email,isemail:1})
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
          @user.valid?
          @user.save(:validate=>false)
          # 好的！在这一点上，我们就可以往UC那边写入真正的auth了！
          UCenter::ThirdPartyAuth.getauth(nil,{uc_uid:@user.uid.to_s,uid:@auth[:uid],provider:@auth[:provider],will_create:true,oauth_succeeded:true})
        else
          raise '注册UC同步注册错误！！！猿快来看一下！'
        end
      else
        User.import_from_dz!(info0)
      end
    end
    sign_in(@user);sign_in_others
    if @user.reg_extent_okay?
      redirect_to(root_path, :notice =>  '谢谢！您已经成功登录。')
    else
      redirect_to "/register05"
      return false
    end
  end
end

