# -*- encoding : utf-8 -*-
class ReportSpam
  include Mongoid::Document
  include Mongoid::Timestamps
  include BaseModel
  field :url
  field :descriptions, :type => Array, :default => []
  field :handled_at, :type => Time
  field :handler_id
  field :handled_text
  field :reportor_id

  # index :url
  validates_presence_of :descriptions

  def self.add(url, description, user_name, user_id)
    report = ReportSpam.new
    report.reportor_id=user_id
    report.url=url
    report.descriptions << "#{user_name}:\n#{description}"
    report.save
  end
  
  def send_mailer
    user=User.where(:_id=>self.reportor_id).first
    if !user.blank?
      UserMailer.deliver_delayed(UserMailer.report_spam_back(self.id,user.email))
    end
  end
  
end
