# -*- encoding : utf-8 -*-
class HookerJob
  include Sidekiq::Worker
  sidekiq_options :queue => :hooker
  def perform(klass,id,method,*args)
    sendee = klass.constantize
    if !id.nil?
      sendee = sendee.find(id)
    end
    sendee.send(method,*args)
  end
end
