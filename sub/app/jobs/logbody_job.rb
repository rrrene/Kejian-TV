# -*- encoding : utf-8 -*-
class LogbodyJob
  include Sidekiq::Worker
  sidekiq_options :queue => :redundancy
  def perform(params={})
    @log = Log.find(params['log_id'])
    view = ActionView::Base.new('app/views')
    view.extend ApplicationHelper
    view.extend AsksHelper
    view.extend TopicsHelper
    view.extend UsersHelper
    str = view.render(file:'logs/_log.html',locals:{log:@log,force_raw:true})
    @log.update_attribute(:body,str)
  end
end
