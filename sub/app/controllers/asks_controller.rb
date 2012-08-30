# coding: UTF-8
class AsksController < ApplicationController
  before_filter :authenticate_user!, :only => [:answer,:create]
  before_filter :require_user_js, :only => [:answer,:invite_to_answer]
  before_filter :require_user_text, :only => [:update_topic,:redirect,:spam, :mute, :unmute, :follow, :unfollow]
    layout 'for_help'

  def index
    suggest
    @per_page = 20
    @asks = Ask.nondeleted.normal
    if request.path=='/zero_asks'
      @asks = @asks.unanswered.where(:to_user_id=>nil).where(:created_at.gt=>Time.now-30.days)
    end
    @asks = @asks.recent.where(:no_display_at_index.ne=>true).paginate(:page => params[:page], :per_page => @per_page)
    
    if request.path=='/zero_asks'
      set_seo_meta("悬而未决的题")
    else
      set_seo_meta("所有题")
    end
    
    if '1'==params[:force_mobile]
      if '1'==params[:force_js]
        render 'index.mobile.js',layout:false
      else
        render 'index.mobile',layout:'application.mobile'
      end
    else
      render
    end
  end

  def search
    # @asks = Ask.search_title(params["w"],:limit => 20)[:items]
    set_seo_meta("关于“#{params[:w]}”的搜索结果")
    render "index"
  end

  def show
    @we_are_no_zm_header = true
    begin
      @ask = Ask.nondeleted.where(_id:BSON::ObjectId(params[:id])).first
    rescue => e
      render_404
      return
    end

    if !@ask
      render_404
      return
    end
    @ask.view!

    if !@ask.redirect_ask_id.blank?
      if params[:nr].blank?
        # 转向题
        redirect_to ask_path(@ask.redirect_ask_id,:rf => params[:id], :nr => "1", :force_mobile=>params[:force_mobile])
        return
      else
        @r_ask = Ask.find(@ask.redirect_ask_id)
      end
    end

    if params[:rf]
      @rf_ask = Ask.find(params[:rf])
      if !@ask.redirect_ask_id.blank?
        @r_ask = Ask.find(@ask.redirect_ask_id)
      end
    end
    
    # 由于 voteable_mongoid 目前的按 votes_point 排序有题，没投过票的无法排序
    @answers = @ask.answers.nondeleted
    if 'new'==params[:filter]
      @answers = @answers.desc('created_at')
    else
      @answers = @answers.order_by(:"votes.up_count".desc,:"votes.down_count".asc,:"created_at".asc) # :spams_count.asc,
    end
    @answer = Answer.new
    # 推荐领域,如果没有设置领域的话
    @suggest_topics = AskSuggestTopic.find_by_ask(@ask)
    set_seo_meta(@ask.title)
    @invites = @ask.ask_invites
    if current_user
      @relation_asks = AskSuggestAsk.find_by_ask(@ask).limit(10) - current_user.followed_ask_ids
    else
      @relation_asks = AskSuggestAsk.find_by_ask(@ask).limit(10)
    end
    respond_to do |format|
      format.html{
        if '1'==params[:force_mobile]
          render 'show.mobile',layout:'application.mobile'
        else
          render
        end
      } # show.html.erb
      format.json
    end
  end

  def redirect
    return render :text => "-2" if params[:id] == params[:new_id]
    @ask = Ask.find(params[:id])
    if params[:cancel].blank?
      render :text => @ask.redirect_to_ask(params[:new_id])
    else
      @ask.redirect_cancel
      render :text => "1"
    end
  end

  def share
    @ask = Ask.find(params[:id])
    current_user.inc(:share_count,1)
    @ask.inc(:shared_count,1)
    if request.get?
      if current_user
        render "share", :layout => false
      else
        render_404
      end
    else
      case params[:type]
      when "email"
        if params[:to]!="" and params[:subject]!="" and params[:body]!=""
          UserMailer.simple(params[:to], params[:subject], params[:body].gsub("\n","<br />")).deliver
          flash[:notice] = "已经将题连接发送到了 #{params[:to]}"
        elsif  params[:to]==""
          flash[:notice] = "收件人不能为空！"
        else
          flash[:notice] = "主题与正文不能为空！"
        end
        redirect_to "/asks/#{params[:id]}"
      end
    end

  end

  def answer
    if current_user.user_type==User::FROZEN_USER
      render text:'window.location.href="/frozen_page"'
      return
    end
    if SettingItem.get_deleted_nin_boolean
      Deferred.create!(user_id:current_user.id,controller:'answers', body:params, content:params[:answer][:body])
      flash[:notice] = "答案"
      render text:'window.location.href="/under_verification"'
      return
    end

=begin
an params example:
{"utf8"=>"✓", "authenticity_token"=>"Vl5Cm0DN8IuKznybqT5DratuEaL9kb0E/1AzgsIBtgs=", "answer"=>{"body"=>"fdsfdffddfd332213232"}, "action"=>"answer", "controller"=>"asks", "id"=>"4e66d5046130032a31000032"}
=end

    @ask,@success,@answer = Answer.real_create(params,current_user)
    if @success and SettingItem.where(:key=>"answer_advertise_limit_open").first.value=="1"
      Resque.enqueue(HookerJob,"User",@answer.user_id,:answer_advertise,@answer.id)
    end
    respond_to do |format|
      format.html{
        if '1'==params[:force_mobile]
          redirect_to "/asks/#{@answer.ask.id}?force_mobile=1"
        else
          redirect_to "/asks/#{@answer.ask.id}"
        end
      }
      format.js
    end
  end

  def spam 
    @ask = Ask.find(params[:id])
    size = 1
    if(current_user and current_user.admin?)
      size = Setting.ask_spam_max
    end
    count = @ask.spam(current_user.id,size)
    render :text => count
  end

  def follow
    @ask = Ask.find(params[:id])
    if params[:follow].blank?
      follow = false
    else
      follow = true
    end
    res = current_user.follow_ask(@ask,follow)
    render :text => res
  end
  
  def new
    @ask = Ask.new
    if '1'==params[:force_mobile]
      render 'new.mobile'
    else      

      respond_to do |format|
        format.html # new.html.erb
        format.json
      end
    
    end
  end
  
  def edit
    @ask = Ask.find(params[:id])
  end
  
  def create
    if current_user.user_type==User::FROZEN_USER
      render file:'shared/banished' and return
      return
    end
    if SettingItem.get_deleted_nin_boolean
      Deferred.create!(user_id:current_user.id,controller:'asks', body:params, content:params[:ask][:title])
      flash[:notice] = "题"
      redirect_to "/under_verification"
      return
    end

=begin
an params example:
{"authenticity_token"=>"Vl5Cm0DN8IuKznybqT5DratuEaL9kb0E/1AzgsIBtgs=", "ask"=>{"title"=>"标题", "body"=>"内容"}, "topic"=>"", "topics"=>"", "action"=>"create", "controller"=>"asks"}
=end
    ret,@ask,@invite = Ask.real_create(params,current_user)
    case ret
    when 1
      flash[:notice] = ""
      if '1'==params[:force_mobile]
        redirect_to("/asks/#{@ask.id}?force_mobile=1",:notice => '已有相同的题存在。') and return
      else
        redirect_to ask_path(@ask.id, :notice => '已有相同的题存在。')
      end

    when 2
      if SettingItem.where(:key=>"ask_advertise_limit_open").first.value=="1"
        Resque.enqueue(HookerJob,"User",@ask.user_id,:ask_advertise,@ask.id)
      end
      if '1'==params[:force_mobile]
        redirect_to("/mobile/noticepage",:notice => '题创建成功。<a href="/asks/'+@ask.id.to_s+'?force_mobile=1">点击这里</a>跳转到该题。') and return
      else
        redirect_to(ask_path(@ask.id), :notice => '题创建成功。')
      end
    else
      if '1'==params[:force_mobile]
        render file:'asks/new.mobile' and return
      else
        render :action => "new"
      end
    end
    
  end
  
  def update
    @ask = Ask.find(params[:id])
    @ask.current_user_id = current_user.id

    respond_to do |format|
      if @ask.update_attributes(params[:ask])
        format.html { redirect_to(ask_path(@ask.id), :notice => '题更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end

  def update_topic
    @name = params[:name].strip
    @add = params[:add] == "1" ? true : false
    @ask = Ask.find(params[:id])
    if @ask.update_topics(@name,@add,current_user.id)
      current_user.follow_topic(Topic.find_by_name(@name))
      @success = true
    else
      @success = false
    end
    if not @add
      render :text => @success
    end
  end

  def mute
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.mute_ask(@ask.id)
    render :text => "1"
  end
  
  def unmute
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.unmute_ask(@ask.id)
    render :text => "1"
  end
  
  def follow
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.follow_ask(@ask)
    render :text => "1"
  end
  
  def unfollow
    @ask = Ask.find(params[:id])
    if not @ask
      render :text => "0"
      return
    end
    current_user.unfollow_ask(@ask)
    render :text => "1"
  end

  def invite_to_answer
    drop = params[:drop] == "1" ? true : false
    if drop
      @id=params[:i_id]
      @ask= AskInvite.cancel(params[:i_id], current_user.id)
      render :action=>'invite_to_answer_drop'
    else
      if (current_user.id.to_s != params[:user_id].to_s)
        current_user.inc(:invite_count,1)
        User.find(params[:user_id]).inc(:invited_count,1)
        @invite = AskInvite.invite(params[:id], params[:user_id], current_user.id)
        @success = true
      else
        @success = false
      end
    end
  end
  
end
