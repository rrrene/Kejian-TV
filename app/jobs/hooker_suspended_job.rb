# -*- encoding : utf-8 -*-
class HookerSuspendedJob
  include Sidekiq::Worker
  sidekiq_options :queue => :hooker_suspended
  def perform(klass,id,method,*args,&block)
    sendee = klass.constantize.find(id)
    sendee.send(method,*args,&block)
  end
end
