# -*- encoding : utf-8 -*-
class WinTransJobPPT
  include Sidekiq::Worker
  sidekiq_options :queue => :win_transcoding_ppt
  def perform(remote_url,extname,cw_id)
  end
end
