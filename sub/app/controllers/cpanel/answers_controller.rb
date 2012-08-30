# coding: UTF-8
class Cpanel::AnswersController < CpanelController
  before_filter :require_answer_admin
  def verify
    @answer = Deferred.answers.find(params[:id])
    @answer.verify!
    redirect_to '/cpanel/answers_un2'
  end
  def index_un2
    @answers = Deferred.answers.desc("created_at").paginate(:page => params[:page], :per_page => 40) #.includes([:user])
    respond_to do |format|
      format.html
      format.json
    end
  end
  def index_un2all
    Deferred.answers.all.each do |item|
      Resque.enqueue(HookerJob,'Deferred',item.id,:verify!)
    end
    redirect_to '/cpanel/answers_un2', notice:'已经在后台开始全部审核，稍后才能看到结果'
  end
  def index
    @no_form_search=true
    #params[:q] = params[:q].strip if params[:q]
    @answers = Answer
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?
      @answers = @answers.any_in(:user_id=>ids)
    elsif !params[:user_name].blank?
      @answers = @answers.any_in(:user_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    if !params[:body].blank?
      @answers = @answers.where(:body=>/#{params[:body].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
    end
    if !params[:title].blank?
      ask_ids = Ask.where(:title=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/).map{|x|x.id}
      @answers =@answers.any_in(:ask_id=>ask_ids)
    end
    if !params['datepicker_from'].blank? and !params["time_from"].blank?
      @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%Y-%m-%d %H:%M"
      @answers = @answers.where(:created_at.gt=>@from_time)
    elsif((!params['datepicker_from'].blank? and params["time_from"].blank?) or (params['datepicker_from'].blank? and !params["time_from"].blank?))
      flash.now[:notice]="起始时间格式不正确！"
    end
    if !params['datepicker_to'].blank? and !params["time_to"].blank?
      @to_time = Time.strptime params['datepicker_to']+' '+params["time_to"],"%Y-%m-%d %H:%M"
      @answers = @answers.where(:created_at.lt=>@to_time)
    elsif((!params['datepicker_to'].blank? and params["time_to"].blank?) or (params['datepicker_to'].blank? and !params["time_to"].blank?))
      flash.now[:notice]="终止时间格式不正确！"
    end
    if !@from_time.blank? and !@to_time.blank? and @from_time>@to_time
      flash.now[:notice]="时间范围不正确！"
    end
    if !params[:vote_up_count_left].blank?
      @answers = @answers.where(:vote_up_count.gte=>params[:vote_up_count_left].to_i)
    end
    if !params[:vote_up_count_right].blank?
      @answers = @answers.where(:vote_up_count.lte=>params[:vote_up_count_right].to_i)
    end
    if !params[:vote_down_count_left].blank?
      @answers = @answers.where(:vote_down_count.gte=>params[:vote_down_count_left].to_i)
    end
    if !params[:vote_down_count_right].blank?
      @answers = @answers.where(:vote_down_count.lte=>params[:vote_down_count_right].to_i)
    end
    if !params[:comments_count_left].blank?
      @answers = @answers.where(:comments_count.gte=>params[:comments_count_left].to_i)
    end
    if !params[:comments_count_right].blank?
      @answers = @answers.where(:comments_count.lte=>params[:comments_count_right].to_i)
    end
    if !params[:thanked_count_left].blank?
      @answers = @answers.where(:thanked_count.gte=>params[:thanked_count_left].to_i)
    end
    if !params[:thanked_count_right].blank?
      @answers = @answers.where(:thanked_count.lte=>params[:thanked_count_right].to_i)
    end
    if !params[:spams_count_left].blank?
      @answers = @answers.where(:spams_count.gte=>params[:spams_count_left].to_i)
    end
    if !params[:spams_count_right].blank?
      @answers = @answers.where(:spams_count.lte=>params[:spams_count_right].to_i)
    end
    if !params[:user_type].blank? and params[:user_type].to_i==User::EXPERT_USER
      #user_ids=User.where(:user_type=>params[:user_type].to_i).map{|x|x.id}
      user_ids=User.where(:user_type=>User::EXPERT_USER).map{|x|x.id}
      @answers =@answers.any_in(:user_id=>user_ids)
    elsif !params[:user_type].blank? and params[:user_type].to_i==User::NORMAL_USER
      user_ids=User.where(:user_type.in=>[User::EXPERT_USER,User::ELITE_USER]).map{|x|x.id}
      @answers =@answers.not_in(:user_id=>user_ids)
    elsif !params[:user_type].blank? and params[:user_type].to_i==User::ELITE_USER
      user_ids=User.where(:user_type=>User::ELITE_USER).map{|x|x.id}
      @answers =@answers.any_in(:user_id=>user_ids)
    end
    if params[:sort_by]=="vote_up_count"
      @answers = @answers.desc("vote_up_count")
    elsif params[:sort_by]=="vote_down_count"
      @answers = @answers.desc("vote_down_count")
    elsif params[:sort_by]=="comments_count"
      @answers = @answers.desc("comments_count")
    elsif params[:sort_by]=="thanked_count"
      @answers = @answers.desc("thanked_count")
    elsif params[:sort_by]=="spams_count"
      @answers = @answers.desc("spams_count")
    else
      @answers = @answers.desc("created_at")
    end
    @answers = @answers.nondeleted
    @answers = @answers.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @answer = Answer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @answer = Answer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @no_form_search=true
    @answer = Answer.find(params[:id])
  end
  
  def create
    @answer = Answer.new(params[:answer])

    respond_to do |format|
      if @answer.save
        format.html { redirect_to(cpanel_answers_path, :notice => 'Answer 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @answer = Answer.find(params[:id])
    params[:answer][:body]=params[:content]
    params[:answer][:spams_count]=(params[:answer][:spams_count].to_i>0 ? (params[:answer][:spams_count].to_i):0)
    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        format.html { redirect_to(cpanel_answers_path, :notice => 'Answer 更新成功。') }
        format.json
      else
        format.html { redirect_to(edit_cpanel_answer_path(@answer), :notice => 'Answer 更新失败！') }
        format.json
      end
    end
  end
  
  def destroy
    if params[:deferred].present?
      Deferred.answers.find(params[:id]).delete
      redirect_to("/cpanel/answers_un2",:notice => "删除成功。")
    else
      @answer = Answer.find(params[:id])
      # AnswerLog.any_of(target_id:@answer.id,target_ids:@answer.id,target_parent_id:@answer.id).destroy_all
      # @answer.destroy
      @answer.soft_delete(true)
      redirect_to("/cpanel/answers",:notice => "删除成功。")
    end
  end
  
  def deal_answers
    if !params[:choose_answers].blank? and !params[:deal_action].blank?
      answers=Answer.any_in(:_id=>params[:choose_answers])
      if params[:deal_action].to_i==1
        answers.each do |a|
          a.soft_delete(true)
          a.info_delete(current_user.id)
        end
        notice="Answers 处理成功。"
      elsif params[:deal_action].to_i==2
        users=[]
        answers.each do |a|
          users<<a.user_id
        end
        users.uniq.each do |user|
          u=User.where(:_id=>user).first
          if !u.blank?
            u.soft_delete(true)
            u.info_delete(current_user.id)
          end
        end
        notice="Answers 处理成功。"
      end
    else
      notice="Answers 处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(cpanel_answers_path, :notice => notice) }
      format.json
    end
  end
  
  def require_answer_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("answer")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
