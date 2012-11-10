# -*- encoding : utf-8 -*-
class InjectTranscoderJob
  include Sidekiq::Worker
  sidekiq_options :queue => :transcoding
  # basically, this is the essense
  # of auxiliary/ibeike_*.rb
  def perform(mode,opts={})
              # ok,so
              # at this moment
              # we have no idea what the subsite data is
              # we are 
              # doing on the 0db5.com's behalf
    opts = opts.with_indifferent_access
    if :dz.to_s== mode.to_s
      # subsite = cnu
      # tid = 1
      # author = psvr
      # sort = ppt
      # pdf_filename = "iBeiKe课件共享系统（OCW）.pdf"
      # dz_filepath = "/home/main/ktv/sub/simple/simple/data_cnu/attachment/forum/201208/29/103115e5ouor4w6mb0aqlm.attach"
      # title = title: "讲义: 2.3 定点运算器的组成"
      p = {}
      p[:pdf_filename]=File.basename(opts[:pdf_filename])
      p[:title] = opts[:title] unless opts[:title].present?
      if ['ppt','pptx','doc','docx'].include? opts[:sort].downcase
        rest = opts[:dz_filepath].split('/home/main/ktv/sub/simple/')[-1].split('/').collect{|x| CGI::escape(x.to_s)}.join('/')
        p[:remote_filepath]="http://#{opts[:subsite]}.0db5.com/#{rest}"
      else
        p[:remote_filepath]=opts[:dz_filepath]
      end
      p[:really_localhost]=true
      p[:really_localpath]=opts[:dz_filepath]
      p[:subsite] = opts[:subsite]
      p[:tid]=opts[:tid]
      user = User.find_by_slug(opts[:author])
      Courseware.presentations_upload_finished(p,user)
    end
  end
end

