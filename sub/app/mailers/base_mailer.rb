class BaseMailer < ActionMailer::Base
  default :from => Setting.email_sender, :content_type => "text/html", :charset => "utf-8"
  helper :application,:users,:asks
  layout "mailer"

  def self.deliver_delayed(mail)
    begin
      #todo many todos
      user = User.where(email:mail.to[0].downcase).first
      if user
        user.current_mails ||= []
        user.current_mails << [mail.subject.to_s,mail.body.to_s]
        user.save(:validate=>false)
      else
        mail.deliver
      end
    rescue Exception=>e
      p e
    end
  end

end
