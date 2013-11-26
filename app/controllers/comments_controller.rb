# -*- encoding : utf-8 -*-
class CommentsController < ApplicationController
  before_filter :require_user,:only=>[:new,:update,:edit,:destroy]
  before_filter :require_user_js, :only => [:create]

  def index
    if !params[:type].nil?
        @type = params[:type]
        @id = params[:id]
        @per_page = 10
        @comments = Comment.where(:commentable_type => @type.titleize, :commentable_id => Moped::BSON::ObjectId(@id)).nondeleted.desc("created_at").to_a
        @comments = @comments.paginate(:page => params[:page], :per_page => @per_page)
        @comment = Comment.new(:commentable_type => @type.titleize, :commentable_id => @id)
    else
        redirect_to '/'
    end
  end

  def create
    if current_user.user_type==User::FROZEN_USER
      render text:'window.location.href="/frozen_page"'
      return
    end
    if params[:comment][:body].blank? and params[:comment][:body].length < 5
      render text:'请填写内容，最短5个字'
      return
    end
    if SettingItem.get_deleted_nin_boolean
      Deferred.create!(user_id:current_user.id,controller:'comments', body:params, content:params[:comment][:body])
      flash[:notice] = "评论"
      render text:'window.location.href="/under_verification"'
      return
    end
    if !current_user.last_comment_at.nil? and Time.now - current_user.last_comment_at < 10
        # flash[:notice] = "评论最短间隔为#{10}s"
        render text:"评论最短间隔为#{10}s"
        return
    end
=begin
an params example:
{"utf8"=>"✓", "authenticity_token"=>"Vl5Cm0DN8IuKznybqT5DratuEaL9kb0E/1AzgsIBtgs=", "comment"=>{"commentable_type"=>"Ask", "commentable_id"=>"4e66d5046130032a31000032", "body"=>"fddfsfdfsfdssfd"}, "action"=>"create", "controller"=>"comments"}
=end
    User.find(current_user.id).update_attribute(:last_comment_at,Time.now)
    @success,@comment = Comment.real_create(params,current_user)
    if @success and SettingItem.where(:key=>"answer_advertise_limit_open").first.value=="1"
      Sidekiq::Client.enqueue(HookerJob,"User",@comment.user_id,:comment_advertise,@comment.id)
    end
    if 'Courseware'==@comment.commentable_type
      if @comment.replied_to_comment_id.nil?
          CwEvent.add_action('评论课件','Comment',@comment.id,request.ip,request.url,current_user.id,true,@is_mobile)
      else
          CwEvent.add_action('评论评论','Comment',@comment.id,request.ip,request.url,current_user.id,true,@is_mobile)
      end
      @comment.save(:validate=>false)
      if !@comment.nil?
          render 'coursewares/_cw_comment',locals:{comment:@comment,data_score:0},layout:false
      end
    end
  end

  def show
    render text:'deprecated.',status:405    
  end
  def new
    render text:'deprecated.',status:405    
  end
  def update
    render text:'deprecated.',status:405    
  end
  def edit
    render text:'deprecated.',status:405    
  end
  def destroy
    render text:'deprecated.',status:405    
  end

end
