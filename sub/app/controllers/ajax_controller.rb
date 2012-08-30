# coding: utf-8
class AjaxController < ApplicationController
  before_filter :authenticate_user!, :except => [:checkUsername,:checkEmailAjax,:xl_req_get_method_vod,:logincheck,:seg,:star_refresh]
  def checkUsername
    render json:{okay:Ktv::Renren.name_okay?(params[:q])}
  end
  def checkEmailAjax
    render json:{okay:(0==User.where(:email => params[:q]).count)}
  end
  def xl_req_get_method_vod
    h = {
      resp:XunleiInfo.xunlei_url_find_or_create(params[:url]).info
    }
    render text:"#{params[:jsonp]}(#{h.to_json})"
  end
  def logincheck
    params[:userEmail] = params[:userEmail].strip
    u = User.where(email:params[:userEmail]).first
    if u.nil?
      render text:'此E-mail尚未注册'
    elsif u.access_locked?
      render text:'您的账号因多次登录失败已锁定1小时，请等待或索取解锁邮件'
    elsif u.banished
      render text:'您的账号已被禁，请联系管理员'
    elsif !u.confirmed?
      if u.authorizations_count > 0
        render text:"此E-mail尚未激活，但关联了#{u.authorizations.collect{|au| Ktv::Consumers[au.provider][3]}}.join('、')账号，您可以先用它们登录然后设置邮箱"
      else
        render text:'此E-mail尚未激活，请点击邮件里的激活链接，或重发激活邮件'
      end
    elsif u.encrypted_password.empty?
      if u.authorizations_count > 0
        render text:"此账号尚未设置密码，但关联了#{u.authorizations.collect{|au| Ktv::Consumers[au.provider][3]}}.join('、')账号，您可以先用它们登录然后设置密码"
      else
        render text:'此账号尚未设置密码，请点击邮件里的激活链接激活账户并设置密码'
      end
    else
      render text:'0'
    end
  end
  def presentations_upload_finished
    presentation = params[:presentation]
=begin
authenticity_token	TYtQltBs1pbFLaRKHmne6sB/HHzwPhdKJrHmO+E0dSk=
presentation[category_id]	
presentation[description]	
presentation[id]	50002148100c37000104076b
presentation[name]	
presentation[pdf_filename]	Predefined Global Variables (Read Ruby 1.9).pdf
presentation[publish]	0
presentation[publish]	1
presentation[published_at]	2012/07/13
utf8	✓
=end
    cw = Courseware.where(:_id => presentation[:id]).first
    cw = Courseware.new if cw.nil?
    cw.uploader_id = current_user.id
    cw.pdf_filename = presentation[:pdf_filename]
    cw.sort = File.extname(cw.pdf_filename).split('.')[-1]
    cw.topic = presentation[:topic]
    if cw.topic.blank?
      cw.topic = '领域请求' 
    else
      cookies[:presentation_topic] = cw.topic
    end
    cw.title = presentation[:title]
    cw.title = File.basename(cw.pdf_filename) if cw.title.blank?
    cw.title = '课件标题请求' if cw.title.blank?
    cookies[:presentation_pretitle] =  (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
    cw.remote_filepath = "http://ktv-up.b0.upaiyun.com/#{current_user.id}/#{presentation[:uptime]}.pdf"
    cw.status = 1
    cw.save!
    current_user.inc(:coursewares_upload_count,1)

    case cw.sort.to_sym
    when :pdf,:djvu
      Resque.enqueue(TranscoderJob,cw.id)
    when :ppt,:pptx,:doc,:docx
      Resque.enqueue(WinTransJob,cw.remote_filepath,cw.sort,cw.id)
    end
    json = {
      category_ids: [ nil ],
      created_at: '2012-07-13T09:53:10-04:00',
      creator_id: '4f2fb64e0f6f27001f010a3a',
      description: cw.desc,
      event_id: nil,
      featured_at: nil,
      id: "#{cw.id}",
      likes_count: 0,
      name: "#{cw.title}",
      pdf_filename: "#{cw.pdf_filename}",
      published_at: '2012-07-13T00:00:00-04:00',
      searches: nil,
      short_url: nil,
      slides: [],
      slug: "#{cw.id}",
      state: 'pending',
      tags: [],
      updated_at: '2012-07-13T09:53:10-04:00',
      updater_id: "#{current_user.id}"
    }
    render json:json
  end
  def presentations_status
    cw = Courseware.find(params[:id])
    if 0==cw.status
      complete = 10
      total = 10
      more = ''
    elsif cw.slides_count > 0
      complete = cw.pdf_slide_processed
      total = cw.slides_count+1
      more = "第#{complete}页, 共#{cw.slides_count}页"
    else
      complete = 0
      total = 10
      more = ''
    end
    percent = complete*1.0 / total * 100
    html = <<HEREDOC
<div id="process_progress" class="progress_bar active">
  <div class="progress_title">#{Courseware::STATE_TEXT[Courseware::STATE_SYM[cw.status]]}#{more}</div>
  <div class="progress_meter" style="width:#{percent.to_i}%"></div>
</div>
HEREDOC
    json = {
      total: total,
      complete: complete,
      html: html
    }
    unless complete<total
      json[:id] = cw.id
    end
    render json:json
  end
  def presentations_update
    @courseware = Courseware.find(params[:id])
    presentation = params[:presentation]
    if presentation[:pdf_filename].present?
      # reupload
      cw = @courseware
      cw.uploader_id = current_user.id
      cw.pdf_filename = presentation[:pdf_filename]
      cw.sort = File.extname(cw.pdf_filename).split('.')[-1]

      cw.topic = presentation[:topic]
      if cw.topic.blank?
        cw.topic = '领域请求' 
      else
        cookies[:presentation_topic] = cw.topic
      end
      cw.title = presentation[:title]
      cw.title = File.basename(cw.pdf_filename) if cw.title.blank?
      cw.title = '课件标题请求' if cw.title.blank?
      cookies[:presentation_pretitle] =  (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
      
      cw.remote_filepath = "http://ktv-up.b0.upaiyun.com/#{current_user.id}/#{presentation[:uptime]}.pdf"
      cw.status = 1
      # reset before re-upload
      cw.slides_count = 0
      cw.pdf_slide_processed = 0
      cw.version += 1
      # over
      cw.save!
      case cw.sort.to_sym
      when :pdf,:djvu
        Resque.enqueue(TranscoderJob,cw.id)
      when :ppt,:pptx,:doc,:docx
        Resque.enqueue(WinTransJob,cw.remote_filepath,cw.sort,cw.id)
      end
      json = {
        category_ids: [ nil ],
        created_at: '2012-07-13T09:53:10-04:00',
        creator_id: '4f2fb64e0f6f27001f010a3a',
        description: cw.desc,
        event_id: nil,
        featured_at: nil,
        id: "#{cw.id}",
        likes_count: 0,
        name: "#{cw.title}",
        pdf_filename: "#{cw.pdf_filename}",
        published_at: '2012-07-13T00:00:00-04:00',
        searches: nil,
        short_url: nil,
        slides: [],
        slug: "#{cw.id}",
        state: 'pending',
        tags: [],
        updated_at: '2012-07-13T09:53:10-04:00',
        updater_id: "#{current_user.id}"
      }
      render json:json
      return
    end
    @courseware.topic = presentation[:topic]
    cw = @courseware
    if cw.topic.blank?
      cw.topic = '领域请求' 
    else
      cookies[:presentation_topic] = cw.topic
    end
    @courseware.title = presentation[:title]
    cw.title = '课件标题请求' if cw.title.blank?
    cookies[:presentation_pretitle] =  (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
    @courseware.save!
    redirect_to @courseware
  end
  def seg
    params[:q] = params[:q].strip
    render text:'' and return if params[:q].blank?
    words = MMSeg.split(params[:q])
    topics = Topic.nondeleted.any_in(:name => words.collect { |w| w.downcase } )
    topics.sort { |a,b| b.followers_count <=> a.followers_count }
    topics_array = topics.collect { |t| t.name }
    if topics_array.length > 8
      topics_array = topics_array[0,8]
    end
    render json:topics_array and return
  end
  def all_unread_notification_num
    json = {"message" => 0,"app" => 0,"system" => 0,"fans" => 0,"at" => 0,"comment" => 0}
    render json:json
  end
  def star_refresh
    @topics_users = User.expert_with_topic(:without => [Setting.zuozheqingqiu_id,params[:except_id]] + (current_user ? [current_user.id] : []))
    render file:'welcome/_star_ul_lis',layout:false
  end
end
