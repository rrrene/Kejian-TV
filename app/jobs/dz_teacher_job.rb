# -*- encoding : utf-8 -*-
class DzTeacherJob
  include Sidekiq::Worker
  sidekiq_options :queue => :_dzteacher
  def perform(arg)
    arg = arg.with_indifferent_access
    
    @fid = arg[:fid]
    @tid = arg[:tid]
    @teacher_name = arg[:teacher]
    admin = Ktv::DiscuzAdmin.new
    admin.start_mode Setting.ktv_sub.to_sym
    admin.add_teacher_from_thread(@fid,@teacher_name)   #ADD Teacher
    
    admin.edit_thread_title_teacher(@fid,@tid,@teacher_name)          #Remove teacher from title
  end
end
