# coding: UTF-8
class CommentsController < ApplicationController
  before_filter :require_user_js, :only => [:create]

  def index
    @type = params[:type]
    @id = params[:id]
    @per_page = 10
    @comments = Comment.where(:commentable_type => @type.titleize, :commentable_id => BSON::ObjectId(@id)).nondeleted.asc("created_at").to_a
    @comments = @comments.paginate(:page => params[:page], :per_page => @per_page)
    @comment = Comment.new(:commentable_type => @type.titleize, :commentable_id => @id)
    respond_to do |format|
      format.any{render file:'comments/index.js.erb'}
    end
  end

  def create
    if current_user.user_type==User::FROZEN_USER
      render text:'window.location.href="/frozen_page"'
      return
    end
    if SettingItem.get_deleted_nin_boolean
      Deferred.create!(user_id:current_user.id,controller:'comments', body:params, content:params[:comment][:body])
      flash[:notice] = "评论"
      render text:'window.location.href="/under_verification"'
      return
    end

=begin
an params example:
{"utf8"=>"✓", "authenticity_token"=>"Vl5Cm0DN8IuKznybqT5DratuEaL9kb0E/1AzgsIBtgs=", "comment"=>{"commentable_type"=>"Ask", "commentable_id"=>"4e66d5046130032a31000032", "body"=>"fddfsfdfsfdssfd"}, "action"=>"create", "controller"=>"comments"}
=end
    @success,@comment = Comment.real_create(params,current_user)
    if @success and SettingItem.where(:key=>"answer_advertise_limit_open").first.value=="1"
      Resque.enqueue(HookerJob,"User",@comment.user_id,:comment_advertise,@comment.id)
    end
    if 'Courseware'==@comment.commentable_type
      render 'coursewares/_cw_comment',locals:{comment:@comment},layout:false
    end
  end
end
