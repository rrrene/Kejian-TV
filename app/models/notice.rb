# -*- encoding : utf-8 -*-
class Notice
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  field :start_at,:type=>Time
  field :end_at,:type =>Time
  field :open,:type=>Boolean,:default=>false

  # index :end_at
  def self.open_notice
    Notice.where(:open=>true).where(:start_at.lt=>Time.now).where(:end_at.gt=>Time.now)
  end
end
