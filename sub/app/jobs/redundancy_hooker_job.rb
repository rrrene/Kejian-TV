# -*- encoding : utf-8 -*-
class RedundancyHookerJob
  include Sidekiq::Worker
  sidekiq_options :queue => :redundancy,'retry' => false
  def perform(klass,id,method,*args)
    sendee = klass.constantize
    if !id.nil?
      sendee = sendee.find(id)
    end
    sendee.send(method,*args)
  end
end
