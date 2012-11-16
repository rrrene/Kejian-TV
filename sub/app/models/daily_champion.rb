# -*- encoding : utf-8 -*-
class DailyChampion
  include Mongoid::Document
  field :day,:type=>Date
  # index :day
  field :upload_user_id
  field :upload_user_score,:type=>Integer,:default=>0
  def self.get_today
    self.find_or_create_by(:day=>Date.today)
  end
  def self.touch_upload_user(user)
    t = get_today
    score = user.coursewares.where(:created_at.gte=>Time.now.at_beginning_of_day).count
    if score>t.upload_user_score
      t.upload_user_id = user.id
      t.upload_user_score = score
      t.save(:validate=>false)
    end
  end
end
