# coding: utf-8
class HomeController < ApplicationController
  before_filter :require_user_text, :only => [:update_in_place,:mute_suggest_item]
  before_filter :authenticate_user!, :except => [:newbie,:about,:index,:general_show,:agreement,:mobile]
  before_filter :we_are_inside_qa
  def we_are_inside_qa
    @we_are_inside_qa = true
  end

  def mobile
    render :layout=>false
  end
  def under_verification
    @render_no_sidebar = true
    @raw_raw_raw = true
    render 'application/under_verification'
  end
  def frozen_page
    render file:'shared/banished' and return
  end
  def refresh_sugg
    suggest
    render :layout=>false
  end
  
  def refresh_sugg_ex
    @topic = Topic.find_by_name(params[:topic])
    render text:'no such topic' and return unless @topic
    # render text:TopicSuggestExpert.find_by_topic(@topic) and return
    @related_expert_ids = TopicSuggestExpert.find_by_topic(@topic)
    @related_expert_ids -=current_user.followed_topic_ids if user_signed_in?
    @related_expert_ids = @related_expert_ids.random(7)
    render :layout=>false
  end

  def agreement
    render 'agreement.html.erb'
  end
  
  def index
    suggest
    @log_no_gedaan=true
    @per_page = 20
    if '1'==params[:force_mobile]
      if current_user
        redirect_to '/asks?force_mobile=1' and return
      else
        redirect_to '/mobile/login' and return
      end
    else
      redirect_to '/newbie' and return if !user_signed_in?
    end
    no_redirect = (request.path=='/root' or !params[:page].blank?)
    if current_user
      @notifies, @notifications = current_user.unread_notifies
      if !no_redirect and current_user.following_ids.size + current_user.followed_ask_ids.size + current_user.followed_topic_ids.size < 10
        redirect_to newbie_path and return
      else
        # TODO: 这里需要过滤掉烂题
        @logs = []
        user_asks=[]
        user_answers=[]
        user_asks_time={}
        user_answers_time={}
        logs=Log.any_of({:user_id.in => current_user.following_ids},
          {:target_id.in => current_user.followed_ask_ids},
          {:target_parent_id.in => current_user.followed_ask_ids})
        .and(:action.in => ["NEW","NEW_ANSWER_COMMENT","NEW_ASK_COMMENT", "AGREE", "EDIT"], :_type.in => ["AskLog", "AnswerLog", "CommentLog", "UserLog"], :created_at.gt=>3.months.ago)
        .excludes(:user_id => current_user.id).desc('created_at')
        logs.each do |log|
          if log._type=="AskLog" and ["NEW","EDIT"].include?(log.action) and user_asks.include?(log.user_id.to_s+"_"+log.target_id.to_s) and (log.created_at+2.days)>user_asks_time[log.user_id.to_s+"_"+log.target_id.to_s]
          elsif log._type=="AnswerLog" and ["NEW","EDIT"].include?(log.action) and user_answers.include?(log.user_id.to_s+"_"+log.target_id.to_s) and (log.created_at+2.days)>user_answers_time[log.user_id.to_s+"_"+log.target_id.to_s]
          else
            unless "AskLog"==log._type and log.ask and !(log.ask.is_normal?)
              @logs<<log
              if log._type=="AskLog"
                if !user_asks.include?(log.user_id.to_s+"_"+log.target_id.to_s)
                  user_asks<<log.user_id.to_s+"_"+log.target_id.to_s
                end
                user_asks_time[log.user_id.to_s+"_"+log.target_id.to_s]=log.created_at
              elsif log._type=="AnswerLog"
                if !user_answers.include?(log.user_id.to_s+"_"+log.target_id.to_s)
                  user_answers<<log.user_id.to_s+"_"+log.target_id.to_s
                end
                user_answers_time[log.user_id.to_s+"_"+log.target_id.to_s]=log.created_at
              end
            end
          end
        end
        @logs=@logs.paginate(:page => params[:page], :per_page => @per_page)

        if @logs.count < 1
          @asks = Ask.normal.any_of({:topics.in => current_user.followed_topic_ids.map{|t| Topic.get_name(t)}}).not_in(:follower_ids => [current_user.id])
          # @asks = @asks.includes(:user)#,:last_answer,:last_answer_user,:topics)
          @asks = @asks.exclude_ids(current_user.muted_ask_ids)
          .desc(:answers_count,:answered_at)
          .nondeleted
          .paginate(:page => params[:page], :per_page => @per_page)
                        
          if params[:format] == "js"
            render "/asks/index.js"
          elsif '1'==params[:force_mobile]
            render '/asks/index.mobile'
          end
        else
          if params[:format] == "js"
            render "/logs/index.js"
          elsif '1'==params[:force_mobile]
            render '/logs/index.mobile'
          else
            render "/logs/index"
          end
        end
      end
    else
      @asks = Ask.normal.recent#.includes(:user)#,:last_answer,:last_answer_user,:topics)
      .nondeleted
      .paginate(:page => params[:page], :per_page => @per_page)
      if params[:format] == "js"
        render "/asks/index.js"
      elsif '1'==params[:force_mobile]
        render '/asks/index.mobile'
      end
    end
  end
  
  def general_show
    render_404 and return unless params[:identifier] and params[:identifier]!=''
    
    #pan>
    # search according to priority
    res = Topic.nondeleted.find_by_name(params[:identifier])
    res ||= Ask.nondeleted.find_by_title(params[:identifier])
    res ||= User.nondeleted.find_by_slug(params[:identifier])
    
    if res.blank? or ((defined? res.deleted) and !res.normal_deleting_status(current_user))
      render_404
    else
      #pan>
      # versatile redirect
      case res.class
      when Topic
        uri="/topics/#{CGI::escape res.name}"
      when Ask
        uri="/asks/#{res.id}"
      when User
        uri="/users/#{CGI::escape res.slug}"
      end
      redirect_to uri
    end
    
  end
  
  def newbie
    suggest
    set_seo_meta('风云榜')
    @already=[]
    @already = current_user.followed_topic_ids if user_signed_in?
    #where(:created_at.gt => 30.days.ago.utc)
    #1. followers_count 100
    #2. asks count 30
    #3. newer newer newer!
    @already_names = @already.collect{|id| if topic=Topic.where(_id:id).first;topic.name;else;nil;end}.compact
    @topics = []
    @topics = TopicCache.not_in(name:@already_names).limit(20).to_a
    @newasks= AskCache.limit(20).collect{|ask_cache| Ask.nondeleted.where(:_id=>ask_cache.ask_id).first}.compact

    if '1'==params[:force_mobile]
      render 'newbie.mobile',layout:'application.mobile'
    else
      render
    end

  end
  
  def timeline
    @per_page = 20
    # @logs = Log.any_in(:user_id => curr)
  end
  
  def followed
    suggest
    @per_page = 20
    @asks = current_user ? current_user.followed_asks.normal : Ask.normal
    # @asks = @asks.includes(:user)#,:last_answer,:last_answer_user,:topics
    @asks = @asks.nondeleted
    .desc(:answered_at,:id)
    .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "index"
    end
  end
  
  def recommended
    suggest
    @per_page = 20
    @asks = current_user ? Ask.normal.any_of({:topics.in => current_user.followed_topic_ids.map{|t| Topic.get_name(t)}}).not_in(:follower_ids => [current_user.id]).and(:answers_count.lt => 1) : Ask.normal
    @asks = @asks.where(:to_user_id=>nil)#.includes(:user)#,:last_answer,:last_answer_user,:topics)
    .exclude_ids(current_user.muted_ask_ids)
    .nondeleted
    .desc(:answers_count,:answered_at)
    .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/recommended.js"
    end
  end

  # 查看用户不感兴趣的题
  # def muted
  #   @per_page = 20
  #   @asks = Ask.normal.includes(:user,:last_answer,:last_answer_user,:topics)
  #                 .only_ids(current_user.muted_ask_ids)
  #                 .desc(:answered_at,:id)
  #                 .paginate(:page => params[:page], :per_page => @per_page)
  # 
  #   set_seo_meta("我屏蔽掉的题")
  # 
  #   if params[:format] == "js"
  #     render "/asks/index.js"
  #   else
  #     render "index"
  #   end
  # end
   
  def update_in_place
    # TODO: Here need to chack permission
    klass, field, id = params[:id].split('__')
    puts params[:id]
    
    params[:value] = simple_format(params[:value].to_s.strip) if params[:did_editor_content_formatted] == "no"

    object = klass.camelize.constantize.find(id)
    # 验证权限,用户是否有修改制定信息的权限
    case klass
    when "user"
      unless view_context.owner?(object)
        render_401
        return
      end
    end
    
    update_hash = {field => params[:value]}
    if ["ask","topic"].include?(klass) and current_user
      update_hash[:current_user_id] = current_user.id
    end
    if object.update_attributes(update_hash)
      if 'body'==field and Answer==object.class
        render :text => object.chomp_body
      else
        render :text => object.send(field).to_s
      end
      object.update_consultant! if "user"==klass
    else
      Rails.logger.info "object.errors.full_messages: #{object.errors.full_messages}"
      render :text => object.errors.full_messages.join("\n"), :status => 422
    end
  end

  # def about
  #   set_seo_meta("关于")
  #   @users = User.any_in(:email => Setting.admin_emails)
  # end

  def mark_all_notifies_as_read
    notifications = current_user.notifications.nondeleted.where(:has_read=>false)
    notifications.each do |notify|
      # Rails.logger.info "mark_notifies_as_read_one\n"
      notify.update_attribute(:has_read, true)
    end
    render :text => "1"
  end


  def mark_notifies_as_read
    if !params[:ids]
      render :text => "0"
    else
      notifications = current_user.notifications.any_in(:_id => params[:ids].split(","))
      notifications.each do |notify|
        # Rails.logger.info "mark_notifies_as_read\n"
        notify.update_attribute(:has_read, true)
      end
      render :text => "1"
    end
  end


  def report
    name = "访客"
    if(!params[:url] or params[:url]=='')
      redirect_to '/'
      return
    end
    if current_user
      name = current_user.name
    end
    unless params[:desc] and params[:desc]!=''
      flash[:error]='不能为空'
      redirect_to params[:url]
      return
    end
    if current_user.already_jubao(params[:url])
      render text:"相同的举报内容已经存在" and return
    end
    ReportSpam.add(params[:url],params[:desc],name,current_user.id)
    flash[:notice] = "举报信息已经提交，谢谢你。"
    redirect_to params[:url]
  end

  def mute_suggest_item
    # UserSuggestItem.mute(current_user.id, params[:type].strip.titleize, params[:id])
    render :text => "1"
  end
  

end
