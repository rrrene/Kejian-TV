# coding: UTF-8
class Cpanel::AutofollowController < CpanelController
  before_filter :require_clear_admin,:only=>["index","index_pos","index_del"]
  before_filter :require_verify_admin,:only=>["verify","deal_verify","edit_verify"]
  before_filter :require_ban_word_admin,:only=>["ban_word","create_ban_word","deal_word"]
  before_filter :require_advertise_admin,:only=>["advertise","deal_advertise","deal_word","edit_ask_advertise","edit_ac_advertise"]
  before_filter :require_deleted_admin,:only=>["deleted","deal_deleted"]
  def index
    @users = User.where(:banished.in=>[true,'1'])
    @no_form_search = true
  end
  
  def index_pos
    @user = User.where(:email=>params[:q]).first
    @user ||= User.where(:slug => params[:q]).first
    render layout:false
  end
  
  def index_del
    begin
      @user = User.find(params[:user_id])
      @user.soft_delete(true)
      @user.info_delete(current_user.id)
    rescue => e
      render text:e and return
    end
    redirect_to '/cpanel/users'
  end
  def verify
    @no_form_search = true
    @verify = SettingItem.find_or_create_by(key:'need_verification').value.to_s
    @verify_start = SettingItem.find_or_create_by(key:'need_verification_start_time').value.to_i
    @verify_end = SettingItem.find_or_create_by(key:'need_verification_end_time').value.to_i
    
    @asks=Deferred
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?
      @asks = @asks.any_in(:user_id=>ids)
    elsif !params[:user_name].blank?
      @asks = @asks.any_in(:user_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    if !params[:title].blank?
      @asks=@asks.where(:content=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
    end
    if params[:content_type].to_s=="answers"
      @asks=@asks.answers
    elsif params[:content_type].to_s=="comments"
      @asks=@asks.comments
    elsif params[:content_type].to_s=="asks"
      @asks=@asks.asks
    end
    @asks=@asks.desc("created_at").paginate(:page => params[:page], :per_page => 20)
  end
  def deal_verify
    if !params[:choose_verifies].blank? and !params[:deal_action].blank?
      asks=Deferred.any_in(:_id=>params[:choose_verifies])
      if params[:deal_action].to_i==1
        asks.each do |a|
          a.delete
        end
        notice="处理成功。"
      elsif params[:deal_action].to_i==2
        users=[]
        asks.each do |a|
          users<<a.user_id
        end
        users.uniq.each do |user|
          u=User.where(:_id=>user).first
          if !u.blank?
            u.soft_delete(true)
            u.info_delete(current_user.id)
          end
        end
        notice="处理成功。"
      elsif params[:deal_action].to_i==3
        asks.each do |a|
          Resque.enqueue(HookerJob,'Deferred',a.id,:verify!)
        end
        notice="处理成功。"
      end
    else
      notice="处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(:back, :notice => notice) }
      format.json
    end
  end
  def edit_verify
    item = SettingItem.where(key:'need_verification').first
    if params[:need_verification]
      item.update_attribute(:value,"1")
    else
      item.update_attribute(:value,"0")
    end
    item_start = SettingItem.where(key:'need_verification_start_time').first
    item_end = SettingItem.where(key:'need_verification_end_time').first
    if params[:time_start].to_i<params[:time_end].to_i
      item_start.update_attribute(:value,params[:time_start].to_i)
      item_end.update_attribute(:value,params[:time_end].to_i)
    else
      item_start.update_attribute(:value,params[:time_end].to_i)
      item_end.update_attribute(:value,params[:time_start].to_i)
    end
    redirect_to '/cpanel/autofollow/verify',:notice=>"修改成功！"
  end
  def ban_word
    @no_form_search=true
    @words=NaughtyWord.where(:deleted=>0)
    if !params[:search_word].blank?
      @words=@words.where(:word=>params[:search_word])
    end
    if params[:search_level] and params[:search_level].to_i!=0
      @words=@words.where(:level=>params[:search_level])
    end
    @words=@words.desc("created_at").paginate(:page => params[:page], :per_page => 20)
  end
  def create_ban_word
    if !params[:create_word].blank? and [1,2].include?params[:create_level].to_i
      word=NaughtyWord.find_or_initialize_by(:word=>params[:create_word])
      word.word=params[:create_word]
      word.created_at=Time.now.getlocal
      word.level=params[:create_level].to_i
      word.user_id=current_user.id
      word.deleted=0
      if word.save
        redirect_to "/cpanel/autofollow/ban_word",:notice=>"创建成功！"
      else
        redirect_to "/cpanel/autofollow/ban_word",:notice=>"创建失败！"
      end
    else
      redirect_to "/cpanel/autofollow/ban_word",:notice=>"请输入关键词！"
    end
  end
  def import_ban_word
    file=params[:ban_file]
    if file
      uploader = BanWordUploader.new
      uploader.store!(file)
    end
    Resque.enqueue(HookerJob,'NaughtyWord',NaughtyWord.first.id,:add_words,current_user.id)
    txt=File.open(File.join(Rails.root,'public/uploads/words.txt'))
    render :text=>"#{txt.lines.count} words is adding."
  end
  def deal_word
    if !params[:choose_words].blank? and !params[:deal_action].blank?
      words=NaughtyWord.any_in(:_id=>params[:choose_words])
      if params[:deal_action].to_i==1
        words.each do |a|
          a.update_attribute(:level,1)
        end
        notice="关键词处理成功。"
      elsif params[:deal_action].to_i==2
        words.each do |a|
          a.update_attribute(:level,2)
        end
        notice="关键词处理成功。"
      elsif params[:deal_action].to_i==3
        words.each do |a|
          a.update_attribute(:deleted,1)
        end
        notice="关键词删除成功。"
      end
    else
      notice="关键词处理失败。"
    end
    respond_to do |format|
      format.html {redirect_to(:back,:notice => notice)}
      format.json
    end
  end
  def advertise
    @no_form_search = true
    
    @ask_open = SettingItem.find_or_create_by(key:'ask_advertise_limit_open').value.to_s
    @ask_time = SettingItem.find_or_create_by(key:'ask_advertise_limit_time_range').value.to_i
    @ask_count = SettingItem.find_or_create_by(key:'ask_advertise_limit_count').value.to_i
    @ask_deal = SettingItem.find_or_create_by(key:'ask_advertise_limit_deal_range').value.to_i
    
    @ac_open = SettingItem.find_or_create_by(key:'answer_advertise_limit_open').value.to_s
    @ac_time = SettingItem.find_or_create_by(key:'answer_advertise_limit_time_range').value.to_i
    @ac_count = SettingItem.find_or_create_by(key:'answer_advertise_limit_count').value.to_i
    @ac_deal = SettingItem.find_or_create_by(key:'answer_advertise_limit_deal_range').value.to_i
    
    if params[:content_type] and params[:content_type]=="Ask"
      @asks=Ask.where(:deleted=>3)
    elsif params[:content_type] and params[:content_type]=="Answer"
      @answers=Answer.where(:deleted=>3)
    elsif params[:content_type] and params[:content_type]=="Comment"
      @comments=Comment.where(:deleted=>3)
    else
      @asks=Ask.where(:deleted=>3)
      @answers=Answer.where(:deleted=>3)
      @comments=Comment.where(:deleted=>3)
    end
    
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?
      if !@asks.blank?
        @asks = @asks.any_in(:user_id=>ids)
      end
      if !@answers.blank?
        @answers = @answers.any_in(:user_id=>ids)
      end
      if !@comments.blank?
        @comments = @comments.any_in(:user_id=>ids)
      end
    elsif !params[:user_name].blank?
      if !@asks.blank?
        @asks = @asks.any_in(:user_id=>ids)
      end
      if !@answers.blank?
        @answers = @answers.any_in(:user_id=>ids)
      end
      if !@comments.blank?
        @comments = @comments.any_in(:user_id=>ids)
      end
      flash.now[:notice]="该用户不存在！"
    end
    
    if !params[:title].blank?
      if !@asks.blank?
        @asks=@asks.where(:title=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
      end
      if !@answers.blank?
        @answers=@answers.where(:body=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
      end
      if !@comments.blank?
        @comments=@comments.where(:body=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
      end
    end
    @asks||=[]
    @answers||=[]
    @comments||=[]
    @asks=(@asks+@answers+@comments).sort{|a,b|b.created_at<=>a.created_at}.paginate(:page => params[:page], :per_page => 20)
  end
  def deal_advertise
    if !params[:choose_advertise].blank? and !params[:deal_action].blank?
      comment_ids=[]
      answer_ids=[]
      ask_ids=[]
      params[:choose_advertise].each do |ca|
        if ca.split("_")[0].to_s=="Comment"
          comment_ids<<ca.split("_")[1].to_s
        elsif ca.split("_")[0].to_s=="Answer"
          answer_ids<<ca.split("_")[1].to_s
        elsif ca.split("_")[0].to_s=="Ask"
          ask_ids<<ca.split("_")[1].to_s
        end
      end
      
      comments=Comment.any_in(:_id=>comment_ids)
      answers=Answer.any_in(:_id=>answer_ids)
      asks=Ask.any_in(:_id=>ask_ids)
      
      if params[:deal_action].to_i==1
        comments.each do |c|
          c.soft_delete(true)
          c.info_delete(current_user.id)
        end
        answers.each do |a|
          a.soft_delete(true)
          a.info_delete(current_user.id)
        end
        asks.each do |a|
          a.soft_delete(true)
          a.info_delete(current_user.id)
        end
        notice="处理成功。"
      elsif params[:deal_action].to_i==2
        users=[]
        comments.each do |c|
          users<<c.user_id
        end
        answers.each do |a|
          users<<a.user_id
        end
        asks.each do |a|
          users<<a.user_id
        end
        users.uniq.each do |user|
          u=User.where(:_id=>user).first
          if !u.blank?
            u.soft_delete(true)
            u.info_delete(current_user.id)
          end
        end
        notice="处理成功。"
      elsif params[:deal_action].to_i==3
        comments.each do |c|
          u=c.user
          c.update_attribute(:deleted,0)
          u.update_attribute(:user_type,User::NORMAL_USER)
        end
        answers.each do |a|
          u=a.user
          a.update_attribute(:deleted,0)
          u.update_attribute(:user_type,User::NORMAL_USER)
        end
        asks.each do |a|
          u=a.user
          a.update_attribute(:deleted,0)
          a.redis_search_index_create
          u.update_attribute(:user_type,User::NORMAL_USER)
        end
        notice="处理成功。"
      end
    else
      notice="处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(:back, :notice => notice) }
      format.json
    end
  end
  def edit_ask_advertise
    item = SettingItem.where(key:'ask_advertise_limit_open').first
    if params[:ask_advertise_limit_open]
      item.update_attribute(:value,"1")
    else
      item.update_attribute(:value,"0")
    end
    item_time = SettingItem.where(key:'ask_advertise_limit_time_range').first
    item_count = SettingItem.where(key:'ask_advertise_limit_count').first
    item_deal = SettingItem.where(key:'ask_advertise_limit_deal_range').first
    item_time.update_attribute(:value,params[:ask_advertise_limit_time_range].to_i)
    item_count.update_attribute(:value,params[:ask_advertise_limit_count].to_i)
    item_deal.update_attribute(:value,params[:ask_advertise_limit_deal_range].to_i)
    redirect_to '/cpanel/autofollow/advertise',:notice=>"修改成功！"
  end
  def edit_ac_advertise
    item = SettingItem.where(key:'answer_advertise_limit_open').first
    if params[:answer_advertise_limit_open]
      item.update_attribute(:value,"1")
    else
      item.update_attribute(:value,"0")
    end
    item_time = SettingItem.where(key:'answer_advertise_limit_time_range').first
    item_count = SettingItem.where(key:'answer_advertise_limit_count').first
    item_deal = SettingItem.where(key:'answer_advertise_limit_deal_range').first
    item_time.update_attribute(:value,params[:answer_advertise_limit_time_range].to_i)
    item_count.update_attribute(:value,params[:answer_advertise_limit_count].to_i)
    item_deal.update_attribute(:value,params[:answer_advertise_limit_deal_range].to_i)
    redirect_to '/cpanel/autofollow/advertise',:notice=>"修改成功！"
  end
  def deleted
    @no_form_search = true
       
    if params[:content_type] and params[:content_type]=="Answer"
      @asks=Answer.where(:deleted=>1)
    elsif params[:content_type] and params[:content_type]=="Comment"
      @asks=Comment.where(:deleted=>1)
    else
      @asks=Ask.where(:deleted=>1)
    end
    
    if !params[:user_name].blank? and !(ids=User.where(:name=>params[:user_name]).map{|x|x.id}).blank?     
      @asks = @asks.any_in(:user_id=>ids)
    elsif !params[:user_name].blank?
      @asks = @asks.any_in(:user_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    
    if !params[:deletor_name].blank? and !(ids=User.where(:name=>params[:deletor_name]).map{|x|x.id}).blank?
      @asks = @asks.any_in(:deletor_id=>ids)
    elsif !params[:deletor_name].blank?
      @asks = @asks.any_in(:deletor_id=>ids)
      flash.now[:notice]="该用户不存在！"
    end
    
    if !params[:title].blank?
      @asks=@asks.where(:title=>/#{params[:title].gsub(/[()*+.?^$\\|]/){|s|'\\'+s}}/)
    end
    @asks=@asks.desc("created_at").paginate(:page => params[:page], :per_page => 20)
  end
  def deal_deleted
    if !params[:choose_deleted].blank?
      comment_ids=[]
      answer_ids=[]
      ask_ids=[]
      params[:choose_deleted].each do |ca|
        if ca.split("_")[0].to_s=="Comment"
          comment_ids<<ca.split("_")[1].to_s
        elsif ca.split("_")[0].to_s=="Answer"
          answer_ids<<ca.split("_")[1].to_s
        elsif ca.split("_")[0].to_s=="Ask"
          ask_ids<<ca.split("_")[1].to_s
        end
      end
      comments=Comment.any_in(:_id=>comment_ids)
      answers=Answer.any_in(:_id=>answer_ids)
      asks=Ask.any_in(:_id=>ask_ids)
      comments.each do |c|
        c.update_attribute(:deleted,0)
      end
      answers.each do |a|
        a.update_attribute(:deleted,0)
      end
      asks.each do |a|
        a.update_attribute(:deleted,0)
      end
      notice="处理成功。"
    else
      notice="处理失败。"
    end
    respond_to do |format|
      format.html { redirect_to(:back, :notice => notice) }
      format.json
    end
  end
  def require_clear_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and (current_user.admin_area.include?("user_normal") or current_user.admin_area.include?("user_xml"))))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_verify_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("verify")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_ban_word_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("ban_word")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_advertise_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("advertise")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
  def require_deleted_admin
    if !(current_user.admin_type==User::SUP_ADMIN or (current_user.admin_type==User::SUB_ADMIN and current_user.admin_area.include?("deleted")))
      @no_form_search=true
      redirect_to "/cpanel/welcome",:notice=>"权限不足！"
    end
  end
end
