# -*- encoding : utf-8 -*-
class Api::UsersController < ApiController
  before_filter :must_oauth_authorized,:only=>:show,:if=>proc{!api_super_client?}
# safe______________________________________________
  def index
    pagination_get_ready
    if params[:experts].blank? and params[:current_user].blank?
      render json:{error:'it is not allowed to get all users'}
      return
    end
    if params[:current_user].present?
      if api_current_user_slug.blank?
        render text:"Unauthorized access. OAuth Token Required.", status: 401
        return false
      end
      render json:User.find_by_slug(api_current_user_slug)
      return
    elsif params[:current_user].present?
      @users = User.nondeleted
      @users = @users.where(:is_expert=>true) if !params[:experts].blank?
    end
    pagination_over(@users.count)
    @users = @users.paginate(:page => @page, :per_page => @per_page)
    @ret = @users
    render_this!
  end
  def asked
    slug=params[:id]
    user=User.find_by_slug(slug)
    pagination_get_ready
    @asks = user.asks.recent
                  .nondeleted
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
  def asked_to
    slug=params[:id]
    user=User.find_by_slug(slug)
    pagination_get_ready
    @asks = Ask.asked_to(user.id)
    pagination_over(@asks.count)
    @asks = @asks.paginate(:page => @page, :per_page => @per_page)
    @ret = @asks
    render_this!
  end
  def answered
    slug=params[:id]
    user=User.find_by_slug(slug)
    pagination_get_ready
    @answers = user.answers.nondeleted
    pagination_over(@answers.count)
    @answers = @answers.paginate(:page => @page, :per_page => @per_page)
    @ret = @answers
    render_this!
  end
  
  def comments
    slug=params[:id]
    user=User.find_by_slug(slug)
    pagination_get_ready
    @answers = user.comments.nondeleted
    pagination_over(@answers.count)
    @answers = @answers.paginate(:page => @page, :per_page => @per_page)
    @ret = @answers
    render_this!
  end
  def following
    slug=params[:id]
    user=User.find_by_slug(slug)
    @users=user.following_ids
    @asks=user.followed_ask_ids
    @topics=user.followed_topic_ids
    ren = Jbuilder.encode do |json|
      json.users @users
      json.asks @asks
      json.topics @topics
    end
    render text:ren
  end
  def followed
    slug=params[:id]
    user=User.find_by_slug(slug)
    @users=user.follower_ids
    render json:@users
  end

# dangerous___________________________________________________
  def show
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    u=User.find_by_slug(slug)
    u ||= User.where(:email=>params[:email]).first if params[:email].present?
    u ||= User.where(:email=>slug).first
    u ||= User.where(:_id=>slug).first

    render json:u
  end
  
  def suggestions
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    user=User.find_by_slug(slug)
    if user and !(user.followed_topic_ids.blank? and user.following_ids.blank?)
      elim = user.is_expert ? 3 : 2
      ulim = user.is_expert ? 0 : 1
      tlim = 2
      e,u,t = UserSuggestItem.find_by_user(user)
      @suggested_experts =  User.any_in(:_id=>e.random(elim)).not_in(:_id=>user.following_ids)
      @suggested_users = User.any_in(:_id=>u.random(ulim)).not_in(:_id=>user.following_ids)
      @suggested_topics = Topic.any_in(:name=>t.random(tlim))
    end
    ren = Jbuilder.encode do |json|
      json.experts @suggested_experts
      json.users @suggested_users
      json.topics @suggested_topics
    end
    render text:ren
  end
  
  
  def update_avatar
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    user=User.find_by_slug(slug)
    resource = user
    begin
      params['user']["mail_be_followed"] = ('on'==params['user']["mail_be_followed"] ? '1' : '0')
      params['user']["mail_new_answer"] = ('on'==params['user']["mail_new_answer"] ? '1' : '0')
      params['user']["mail_invite_to_ask"] = ('on'==params['user']["mail_invite_to_ask"] ? '1' : '0')
      params['user']["mail_ask_me"] = ('on'==params['user']["mail_ask_me"] ? '1' : '0')
      old_user = User.find_by_slug(params['user']["slug"])
      if !old_user.blank? and old_user.id != resource.id and !params['user']["slug"].blank?
        render json:{ success:false,reason:"修改失败，用户名重复！"}
        return
      end
      if !params['user']["avatar"].blank?
        resource.avatar_changed_at=Time.now
      end
      if resource.update_attributes(params['user'])
        render json:{success:true}
      else
        render json:{success:false,reason:resource.errors.full_messages}
      end
    rescue => e
      render json:{success:false,reason:resource.errors.full_messages}
    end
  end
  def follow_user
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    user=User.find_by_slug(slug)
    resource = user
    @user = User.where(slug:params[:subject]).first
    render json:{error:'resource not found'} and return unless @user.present?
    if 'unfollow'==params[:ac]
      render json:{success:resource.unfollow(@user)}
    elsif 'follow'==params[:ac]
      render json:{success:resource.follow(@user)}
    else
      render json:{error:'ac must be follow or unfollow'}
    end
  end
  def follow_ask
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    user = User.find_by_slug(slug)
    resource = user
    @user = Ask.where(_id:params[:subject]).first
    render json:{error:'resource not found'} and return unless @user.present?
    if 'unfollow'==params[:ac]
      render json:{success:resource.unfollow_ask(@user)}
    elsif 'follow'==params[:ac]
      render json:{success:resource.follow_ask(@user)}
    else
      render json:{error:'ac must be follow or unfollow'}
    end
  end
  def create
    if !api_super_client?
      render text: "Unauthorized access.", status: 401
      return false
    end
    if user=User.where(email:params[:email]).first
      render json:{success:false, errors:['User already exists!'], user:user}
      return
    end
    u = User.new
    u.email = params[:email]
    email = u.email
    u.name = email.split('@').first
            u.password=(Time.now.to_i+(rand*10000).to_i).to_s
            u.password_confirmation=u.password

            u.slug=nil
            u.name = u.name[0..19] if u.name.length > 20
            suc = u.save
            if suc
              u.update_consultant!
              render json:{success:true,user:u}
            else
              render json:{success:false,errors:u.errors.full_messages}
            end
  end
  def follow_topic
    slug=params[:id]
    if !api_super_client? and api_current_user_slug!=slug
      render text: "Unauthorized access.", status: 401
      return false
    end
    user=User.find_by_slug(slug)
    resource = user
    @user = Topic.where(name:params[:subject]).first
    render json:{error:'resource not found'} and return unless @user.present?
    if 'unfollow'==params[:ac]
      render json:{success:resource.unfollow_topic(@user)}
    elsif 'follow'==params[:ac]
      render json:{success:resource.follow_topic(@user)}
    else
      render json:{error:'ac must be follow or unfollow'}
    end
  end
end
