# -*- encoding : utf-8 -*-
class InjectionJsJob
  include Sidekiq::Worker
  sidekiq_options :queue => :_injectionjs
  def perform(fid)
    admin = Ktv::DiscuzAdmin.new
    admin.start_mode Setting.ktv_sub.to_sym
    
    binding.pry
  end
end