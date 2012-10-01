# -*- encoding : utf-8 -*-
class WinTransJobDOC
  include Sidekiq::Worker
  sidekiq_options :queue => :win_transcoding_doc
  def perform(remote_url,extname,cw_id)
    puts "hey yo! bitch! doc"
  end
end
