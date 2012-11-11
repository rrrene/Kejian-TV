# -*- encoding : utf-8 -*-
class JumpEngineController < ApplicationController
  layout:false
=begin
sa 计算方法 详见 application_helper 或者application_controller的  redirect_sa_cal(str)函数
=end
  def url
    @bad = nil
    params[:url] ||= '/'
    @url = CGI::unescape(params[:url])
    if params[:sa].blank? or params[:sa].downcase != redirect_sa_cal(@url)
      @bad = 'bad'
      return false
    end
    
    params[:t] ||= 's' #t =>type s=>search sr => share renren
    case params[:t]
    when 's'
      add_to_search_history
    when 'sr'
      analyze(@url)
    end
    redirect_to @url,:status => :moved_permanently
    return true
  end
  
  def add_to_search_history
    SearchHistory.add_search_jump_history(current_user,params[:keyword],request.referer,request.ip,@url)
  end

  def ktvid_slide_pic
    if !Moped::BSON::ObjectId.legal?(params[:id].to_s)
      redirect_to '/mqdefault.jpg',:status => :moved_permanently      
      return false
    end
    cw = Courseware.where(id:params[:id].to_s).first
    if cw.nil?
      redirect_to '/mqdefault.jpg',:status => :moved_permanently      
      return false
    end
    params[:pic] ||= "thumb_slide_0.jpg"
    pic = params[:pic]
    url = "http://ktv-pic.b0.upaiyun.com/cw/#{cw.ktvid}/#{cw.revision}#{pic}"
    redirect_to url,:status => :moved_permanently      
    return false
  end
end


# if !request.referer.nil? and URI.parse(URI.encode(request.referer)).host.include?('kejian.tv')
#     redirect_to @url
#     return true
# end
