# -*- encoding : utf-8 -*-
class Hooker2Job
  include Sidekiq::Worker
  sidekiq_options :queue => :hooker2,'retry' => false
  def perform(klass,id,method,*args)
    sendee = klass.constantize
    if !id.nil?
      sendee = sendee.find(id)
    end
    sendee.send(method,*args)
  end
end
