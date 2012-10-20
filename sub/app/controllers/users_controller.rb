# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auth_callback]
  before_filter :init_user, :except => [:auth_callback,:index,:hot,:invite,:invite_submit,:test]
  before_filter :require_user,:only=>[:invite,:invite_send]
  def update
    unless view_context.owner?(@user)
      render_401
      return
    end
    @user.avatar=params[:user][:avatar]
    @user.update_consultant!
    @user.save!
    redirect_to "/users/#{@user.slug}",notice:'头像更新成功！'
  end  
  def hot
    @we_are_inside_qa = false
  end
  def invite
    @seo[:title] = '邀请好友注册'
    @user = User.new
    @invited_users = User.where(inviter_ids:current_user.id).desc('confirmation_sent_at')
    render layout:'application_for_devise'
  end
  def invite_submit
    immediately =( '1'==params[:send_immediately])
    user = User.where(:email => params[:user][:email]).first
    if user
      redirect_to invite_users_path,:notice => "这个邮箱已经被注册过了，请 <a href=\"#{'/users/'+user.slug}\">点击这里</a> 访问他/她的个人主页.".html_safe
    else
      user = User.new(:email => params[:user][:email], :name => params[:user][:name])
      user.avatar = params[:user][:avatar]
      if user.save
        user.invite_by(current_user,immediately)
        notice = immediately ? "已向#{user.name}发去邀请，在他/她注册之前，您可以 <a href=\"#{'/users/'+user.slug}\">点击这里</a> 为他/她上传头像与个人简介：）" : "已添加到邀请列表，请必须点击发送按钮系统才会发送邀请邮件。"
        redirect_to invite_users_path,:notice => notice
      else
        @user = user
        render 'invite',layout:'application_for_devise'
      end
    end
  end
  def invite_send
    @user.invite_by(current_user)
    user = @user
    redirect_to invite_users_path,:notice => "已向#{user.name}发去邀请，在他/她注册之前，您可以 <a href=\"#{'/users/'+user.slug}\">点击这里</a> 为他/她上传头像与个人简介：）"
  end
  def index
    @seo[:title] = '我的同学'
    @users = User.all
  end
  def init_user
    @user = User.where(:fangwendizhi=>params[:id]).first
    @user ||= User.find_by_slug(params[:id].force_encoding_zhaopin.split('_').join('.'))
    @user ||= User.where(:_id=>params[:id]).first
    if @user.blank? or !@user.normal_deleting_status(current_user)
      render_404
    end
    @ask_to_user = Ask.new
  end

  def answered
    @per_page = 10
    @asks = Ask.recent.any_in(_id:@user.answered_ask_ids)
    .nondeleted()
    .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("#{@user.name}解答过的题")
    if params[:format] == "js"
      render "/users/answered_asks.js"
    end
  end
  
  def asked_to
    @per_page = 10
    @asks = Ask.asked_to(@user.id)
    if params[:filter]=='new'
      @asks = @asks.unanswered
    end
    @asks = @asks.recent.nondeleted
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("问#{@user.name}的题")

    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "asked"
    end
  end

  def show
  end

  def asked
    @per_page = 10
    @asks = @user.asks.recent
    .nondeleted
    .paginate(:page => params[:page], :per_page => @per_page)
    set_seo_meta("#{@user.name}问过的题")
    if params[:format] == "js"
      render "/asks/index.js"
    end
  end
  
  def following_topics
    @per_page = 20
    @topics = @user.followed_topic_ids.reverse
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的课程")
    if params[:format] == "js"
      render "following_topics.js"
    end
  end
  
  def followers
    @per_page = 20
    @followers = @user.follower_ids.reverse
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("关注#{@user.name}的人")
    if params[:format] == "js"
      render "followers.js"
    end
  end
  
  def following
    @per_page = 20
    @followers = @user.following_ids.reverse
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的人")
    if params[:format] == "js"
      render "followers.js"
    else
      render "followers"
    end
  end
  
  def double_follow
    @per_page = 20
    @followers = (@user.following_ids & @user.follower_ids).reverse
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的人")
    if params[:format] == "js"
      render "followers.js"
    else
      render "followers"
    end
  end
  
  def invites
    @per_page = 20
    @followers = User.where(:inviter_ids=>@user.id,:confirmed_at=>nil).desc('created_at')
    .paginate(:page => params[:page], :per_page => @per_page)
    
    set_seo_meta("#{@user.name}关注的人")
    if params[:format] == "js"
      render "followers.js"
    else
      render "followers"
    end
  end
  
  def follow
    if not @user
      render :text => "0"
      return
    end
    current_user.follow(@user)
    render :text => "1"
  end
  def zm_follow
    if not @user
      render json:false
      return
    end
    current_user.follow(@user)
    render json:true
  end
  
  def unfollow
    if not @user
      render :text => "0"
      return
    end
    current_user.unfollow(@user)
    render :text => "1"
  end
  def zm_unfollow
    if not @user
      render json:false
      return
    end
    current_user.unfollow(@user)
    render json:true
  end

  def auth_callback
		auth = request.env["omniauth.auth"]  
		redirect_to root_path if auth.blank?
    provider_name = auth['provider'].gsub(/^t/,"").titleize
    Rails.logger.debug { auth }

		if current_user
      Authorization.create_from_hash(auth, current_user)
      flash[:notice] = "成功绑定了 #{provider_name} 账号。"
			redirect_to edit_user_registration_path
		elsif @user = Authorization.find_from_hash(auth)
      sign_in @user
			flash[:notice] = "登录成功。"
			redirect_to "/"
		else
      if Setting.allow_register
        @new_user = Authorization.create_from_hash(auth, current_user) #Create a new user
        if @new_user.errors.blank?
          sign_in @new_user
          flash[:notice] = "欢迎来自 #{provider_name} 的用户，你的账号已经创建成功。"
          redirect_to "/"
        else
          flash[:notice] = "#{provider_name}的账号提供信息不全，无法直接登录，请先注册。"
          redirect_to "/register"
        end
      else
        flash[:alert] = "你还没有注册用户。"
        redirect_back_or_default "/login"
      end
		end
  end
  def test
    
    # todo
  end
end
