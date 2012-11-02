# coding: utf-8
class Setting < Settingslogic
  source "#{Rails.root}/config/setting.yml"
  namespace Rails.env
end

class UserMailer < BaseMailer
  def welcome(user_id)
    @user = User.find(user_id)
    @title = "欢迎加入[#{Setting.app_name}]"
    mail(:to => @user.email,:subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'welcome')
  end

  # 问题有了新回答
  def new_answer(answer_id,email)
    @answer = Answer.find(answer_id)
    @ask = Ask.find(@answer.ask_id)
    @title = "问题“#{@ask.title}”有了新的回答"
    mail(:to => email, :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'new_answer')
  end
  # 被关注
  def be_followed(user_id, follower_id)
    @user = User.find(user_id)
    # 跳过，如果用户不允许发邮件
    return if @user.mail_be_followed == false
    @follower = User.find(follower_id)
    @title = "#{@follower.name}在[#{Setting.app_name}]关注了你"
    mail(:to => @user.email,
      :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'be_followed')
  end

  def new_answer_to_followers(answer_id)
    return true
    @answer = Answer.find(answer_id)
    @ask = Ask.find(@answer.ask_id)
    emails = []
    @ask.followers.excludes(:id => @answer.user_id).each do |u|
      # 跳过，如果用户不允许发邮件
      next if u.mail_new_answer == false
      emails << u.email
    end
    emails.each do |email|
      UserMailer.deliver_delayed(new_answer(answer_id,email))
    end
  end


  def invite_to_answer(ask_id, user_id, invitor_ids)
    @user = User.find(user_id)
    @invitors = User.find(invitor_ids)
    @ask = Ask.find(ask_id)
    if(@invitors.length > 1)
      @title = "#{@invitors[0].name}等人邀请你回答《#{@ask.title}》"
    else
      @title = "#{@invitors[0].name}邀请你回答《#{@ask.title}》"
    end
    mail(:to => @user.email, :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'invite_to_answer')
  end

  # 向用户提问
  def ask_user(ask_id)
    @ask = Ask.find(ask_id)
    @user = @ask.to_user
    @title = "#{@ask.user.name}向你询问《#{@ask.title}》"
    mail(:to => @user.email, :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'ask_user')
  end
  
  def report_spam_back(report_id,email)
    @report=ReportSpam.find(report_id)
    @ask=Ask.where(:_id=>@report.url.split("/").last).first
    @title = "#{User.get_name(@report.handler_id)}处理了您举报的《#{@ask.title}》"
    mail(:to => email, :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'report_spam_back')
  end

  def simple(to, subject, content, extra_hash={})
    @title = subject
    @content = content 
    hash = {:to => to, :subject => @title, :from => Setting.email_sender,:template_path => 'user_mailer', :template_name => 'simple'}
    hash = hash.merge(extra_hash)
    mail(hash)
  end


end
