# -*- encoding : utf-8 -*-
class AjaxController < ApplicationController
  before_filter :authenticate_user!, :except => [:checkUsername,:checkEmailAjax,:xl_req_get_method_vod,:logincheck,:seg,:star_refresh,:current_user_reg_extent,:renren_invite]
  def register_huanyihuan
    render json:{status:'suc',html:render_to_string(file:"devise/registrations/_#{params[:res]}_huanyihuan",locals:{fid:params[:fid].to_i,page:params[:page].to_i},:layout=>false, :formats=>[:html])}
  end
  def renren_invite
    agent = request.env['HTTP_USER_AGENT']
    agent = Setting.user_agent if agent.blank?
    if $psvr_really_production
      Sidekiq::Client.enqueue(HookerJob,
        'Ktv::Renren',
        nil,
        'send_invitation',
        agent,current_user.id,params[:renren_uids]
      )
    else
      Ktv::Renren.send_invitation agent,current_user.id,params[:renren_uids]
    end
    render json:{
      suc:true
    }
  end
  def current_user_reg_extent
    render json:{
      extent:current_user.reg_extent,
      psvr_extent_txt:"#{User::EXTENT_TEXT[current_user.reg_extent]}...",
      psvr_extent_txt_prog_width:454*current_user.reg_extent/10,
    }
  end
  def renren_real_bind
    rr = Ktv::Renren.new
    result = rr.send_login!(
      request,
      params[:renren_cookie],
      params[:uniqueTimestamp],
      {
        :email => params[:email],
        :icode => params[:icode],
        :origURL => params[:origURL],
        :domain => params[:domain],
        :key_id => params[:key_id],
        :captcha_type => params[:captcha_type],
        :password => params[:password],
      }
    )
    ret = MultiJson.decode result
    if ret['code']
      if params[:email] =~ /@/ and current_user.email_unknown
        current_user.email_unknown=false
        current_user.skip_reconfirmation!
        current_user.email=params[:email].xi
        current_user.skip_confirmation!
        current_user.save(:validate=>false)
        # current_user.update_attribute(:email,params[:email])
      end
      if params[:email]=~/^1\d{10}$/ and
        material = current_user.sub_user_material
        material ||= current_user.build_sub_user_material
        if material.phone_mobile.blank?
          material.phone_mobile=params[:email].xi
        end
        current_user.save(:validate=>false)
      end
      agent = request.env['HTTP_USER_AGENT']
      agent = Setting.user_agent if agent.blank?
      if $psvr_really_production
        Sidekiq::Client.enqueue(HookerJob,
          'Ktv::Renren',
          nil,
          'import_info',
          agent,result.cookies,current_user.id,ret['homeUrl'],!!params[:guanzhu_ktv],!!params[:fabiao_ktv]
        )
        if current_user.reg_extent_okay?
          # 1表示只是普通的绑定，成功了，没有后续. ok，该干嘛干嘛。
          render json:{okay:1}
        else
          current_user.update_attribute(:reg_extent,1)
          # 2表示这个用户登录ok，继续注册.
          render json:{okay:2}
        end
      else
        Ktv::Renren.import_info agent,result.cookies,current_user.id,ret['homeUrl'],!!params[:guanzhu_ktv],!!params[:fabiao_ktv]
        if current_user.reg_extent_okay?
          # 1表示只是普通的绑定，成功了，没有后续. ok，该干嘛干嘛。
          render json:{okay:1}
        else
          # 2表示这个用户登录ok，继续注册.
          render json:{okay:2}
        end
      end
    else
      render json:{okay:false,failDescription:ret['failDescription']}
    end
  end
  def renren_huanyizhang
    render json:{src:Ktv::Renren.huanyizhang(request,params[:renren_cookie],params[:rnd])}
  end
  def check_fangwendizhi
    ff=User.fangwendizhize(params[:f])
    not_used = true
    not_used = (!User::FORBIDDEN_FANGWENDIZHI.include?(ff)) if not_used
    not_used = ('0'==UCenter::User.update_fangwendizhi(nil,{will_fire:false,fangwendizhi:ff})) if not_used
    render json:{ff:ff,not_used:not_used}
  end
  def watch_later
    if current_user.nil?
      render json:{okay:false,reason:'您尚未登录！'}
      return false
    end
    if params[:courseware_id].blank? or !Moped::BSON::ObjectId.legal?(params[:courseware_id])
      render json:{okay:false,reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    play_list = PlayList.locate(current_user.id,'稍后阅读')
    if play_list.add_one_thing(params[:courseware_id],true)
      render json:{okay:true,msg:'已将此课件添加至您的稍后阅读锦囊中.'}
    else
      render json:{okay:true,msg:'此课件已存在于您的稍后阅读锦囊中.'}
    end
  end
  def checkUsername
    render json:{okay:Ktv::Renren.name_okay?(params[:q])}
  end
  def checkEmailAjax
    ret = (0==User.where(:email => params[:q]).count)
    if(ret)
      u = UCenter::User.get_user(nil,{username:params[:q],isemail:1})
      ret = false unless '0'==u
    end
    render json:{okay:ret}
  end
  def xl_req_get_method_vod
    h = {
      resp:XunleiInfo.xunlei_url_find_or_create(params[:url]).info
    }
    render text:"#{params[:jsonp]}(#{h.to_json})"
  end
  def logincheck
    params[:userEmail] = params[:userEmail].strip
    u = User.find_by_email(params[:userEmail])
    if u.nil?
      render text:'此E-mail尚未注册'
    elsif u.access_locked?
      render text:'您的账号因多次登录失败已锁定1小时，请等待或索取解锁邮件'
    elsif u.banished
      render text:'您的账号已被禁，请联系管理员'
    else
      render text:'0'
    end
  end
  def upload_page_auto_save
    if params[:psvr_f].blank?
      render json:{status:'psvr_f'}
      return false
    end
    presentation = params[:presentation].with_indifferent_access
    cw = Courseware.presentations_upload_finished(presentation,current_user)
    status = "manual"
    if cw.course_fid.nil? #if course_fid is nil,it means this is the first time auto save. if not nil and 运行到这了,means,首先填了psvrf,而且不是首次填写。so manual
      status = 'auto'
    end
    
    cw.course_fid = params[:psvr_f].to_i
    # update teacher
    if !params[:psvr_f].blank?
      teacher = presentation[:teacher] == 'opt_psvr_add_more' ? presentation[:other_teacher] : presentation[:teacher]
      if !teacher.blank?
        Course.where(fid:params[:psvr_f].to_i).first.teachings.find_or_create_by(teacher:teacher).save(:validate=>false)
        Teacher.find_or_create_by(name:teacher,department_fid:params[:psvr_f]).save(:validate=>false)
      end
    end
    cw.license = Courseware::LICENSE_EN_TO_I[presentation[:reuse]]
    cw.upload_persentage = presentation[:upload_persentage].to_i
    cw.keywords = presentation[:keywords].strip.split(' ')
    cw.desc = presentation[:description]
    cw.set_privacy(presentation[:privacy])
    cw.enable_monetization = presentation[:enable_monetization] == 'enable' ? true : false
    cw.monetization_style = presentation[:monetization_style]
    cw.enable_overlay_ads = presentation[:enable_overlay_ads] == 'yes' ? true : false
    cw.trueview_instream = presentation[:trueview_instream] == 'on' ? true : false
    cw.paid_product = presentation[:paid_product] == 'yes' ? true :false
    cw.allow_syndication = presentation[:allow_syndication] == 'no' ? false : true
    cw.allow_comments = presentation[:allow_comments] == 'yes' ? true :false
    cw.allow_comments_detail = presentation[:allow_comments_detail] == 'all' ? 0 : 1
    cw.allow_comment_ratings = presentation[:allow_comment_ratings]
    cw.allow_ratings = presentation[:allow_ratings] == 'yes' ? true : false
    cw.allow_responses = presentation[:allow_responses] == 'on' ? true : false
    cw.allow_responses_detail = presentation[:allow_responses_detail] == 'all' ? 0 : 1
    cw.allow_embedding = presentation[:allow_embedding] == 'on' ? true : false
    cw.creator_share_feeds = presentation[:creator_share_feeds] == 'on' ? true : false
    if cw.save!
      # do nothing
    else
      render json:{status:'error',id:cw.id}
      return false
    end
    unless '课程请求'==cw.topic
      cookies[:presentation_topic] = cw.topic
    end
    cookies[:presentation_pretitle] = (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
    render json:{status:status,id:cw.id}
  end
  
  def presentations_upload_finished
    presentation = params[:presentation]
    cw = Courseware.presentations_upload_finished(presentation,current_user)
    unless '课程请求'==cw.topic
      cookies[:presentation_topic] = cw.topic
    end
    cookies[:presentation_pretitle] = (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
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
      if cw.tree.present?
        complete = (cw.slides_count - cw.transcoding_count)
        total = cw.slides_count
        more = "  第#{complete+1}个子文件,共#{cw.slides_count}个子文件"
      else
        complete = cw.pdf_slide_processed
        total = cw.slides_count + 1 
        more = "第#{complete}页, 共#{cw.slides_count}页"
        if cw.status == 3
          more = ''
        end
      end
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
      state:Courseware::STATE_TEXT[Courseware::STATE_SYM[cw.status]],
      more:more,
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
        cw.topic = '课程请求' 
      else
        cookies[:presentation_topic] = cw.topic
      end
      
      cw.title = presentation[:title]
      cw.title = File.basename(cw.pdf_filename) if cw.title.blank?
      cw.title = '课件标题请求' if cw.title.blank?
      cw.extra_property_fill(presentation)
      cookies[:presentation_pretitle] =  (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
      cw.really_remote = true
      cw.really_localhost = false
      cw.remote_filepath = "http://ktv-up.b0.upaiyun.com/#{current_user.id}/#{presentation[:uptime]}.pdf"
      cw.status = 1
      # reset before re-upload
      cw.slides_count = 0
      cw.pdf_slide_processed = 0
      # --- version ++++++
      cw.version += 1
      cw.uploader_ids[cw.version.to_s]=cw.uploader_id
      cw.created_ats[cw.version.to_s]=cw.created_at
      # --- version ++++++
      # over
      cw.save(:validate=>false)

      cw.enqueue!
      
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
      cw.topic = '课程请求' 
    else
      cookies[:presentation_topic] = cw.topic
    end
    @courseware.title = presentation[:title]
    cw.extra_property_fill(presentation)
    cw.title = '课件标题请求' if cw.title.blank?
    cookies[:presentation_pretitle] =  (cw.title.split(/[:：]/).size>1) ? cw.title.split(/[:：]/)[0] : ''
    cw.uploader_ids[cw.version.to_s]=cw.uploader_id
    cw.created_ats[cw.version.to_s]=cw.created_at
    @courseware.save!
    redirect_to '/mine/my_coursewares'#@courseware
  end
  def prepare_upload
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    config = Array.new
    uptime = Time.now.to_i
    tmp_uptime = uptime
    for i in 0...params[:count].to_i
      uptime = uptime + i
      policy = {
        'save-key' =>  "/#{current_user.id}/#{uptime}.pdf",
        expiration: "#{1.hour.since.to_i}",
        bucket: 'ktv-up',
        'allow-file-type' =>  'pdf,djvu,ppt,pptx,doc,docx,zip,rar,7z',
        'content-length-range' =>  '0,199000000',
      }.to_json
      policy = Base64.encode64(policy).split("\n").join('')
      config << {
        policy: policy,
        signature: Digest::MD5.hexdigest(policy+'&'+'Vv0WpPhlztxkPn7c9F3x3S8zgRE=')
      }
    end
    render json:{status:'suc',uptime:tmp_uptime,config:config}
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
  def get_teachers
    @c = Course.where(fid:params[:psvr_f].to_i).first
    return render_404 unless @c
    @teachers = @c.teachings.collect(&:teacher).uniq
    render json:@teachers
  end
  def get_forum
    @forum = PreForumForum.find(:all,:conditions=>{:fup=>params[:fup].to_i,:type=>'forum'},:select=>"fid,name")
    render json:@forum
    # json:@forum
  end
  def cw_event_add_action(type,title,id,suc)
      if current_user.nil?
          CwEvent.add_action(type,title,id,request.ip,request.url,nil,suc,@is_mobile)
      else
          CwEvent.add_action(type,title,id,request.ip,request.url,current_user.id,suc,@is_mobile)
      end
  end
  def get_cw_operation
    if params[:type] == 'watch-like'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以顶了。</div>"
      else
        cw = Courseware.find(params[:cw_id])
        result = current_user.thank_courseware(cw)
        cw_event_add_action("课件顶",'Courseware',cw.id,true) if result
        render file:'coursewares/_watch_like',locals:{cw_id:params[:cw_id]},layout:false
      end
    elsif params[:type] == 'watch-unlike'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
      else
        cw = Courseware.find(params[:cw_id])
        result = cw.disliked_by_user(current_user)
        cw_event_add_action("课件踩",'Courseware',cw.id,true) if result
        render file:'coursewares/_watch_unlike',locals:{cw_id:params[:cw_id]},layout:false  
      end
    elsif params[:type] == 'addto'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
      else
        render file:'coursewares/_add_to',locals:{cw_id:params[:cw_id]},layout:false  
      end
    elsif params[:type] == 'flag'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
      else
        render file:'coursewares/_flag_panel',locals:{cw_id:params[:cw_id]},layout:false  
      end
    elsif params[:type] == 'stat'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
      else
        render file:'coursewares/_cw_stat',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
      end
    end
    
  end
  ### playlist start
  def add_to_playlist
    #TODO params[:sort] 
    # params[:on_top] true false
    ##TODO  list
    
    json = {status:'suc',title:params[:list_title],comment:'beizhu',time:'123',cw_id:params[:cw_id]}

    render json:json
  end
  def add_comment_to_playlist
    json = {status:'suc',title:params[:list_title],comment:params[:comment],time:'123',cw_id:params[:cw_id]}
    render json:json
  end
  def playlist_sort
    if current_user.nil?
      render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
    else
      render file:'coursewares/_sorted_playlist',locals:{sort:params[:sort]},layout:false  
    end
  end
  def create_new_playlist
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if params[:cwid].blank? or !Moped::BSON::ObjectId.legal?(params[:cwid])
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    if params[:list_title].blank?
      render json:{status:'failed',reason:'请填写课件锦囊名称！'}
      return false
    end
    pl = PlayList.find_or_create_by(user_id:current_user.id,title:params[:list_title])
    pl.desc = params[:desc] if !params[:desc].blank?
    if !params[:is_private].blank?
      case params[:is_private]
      when 'private'
        pl.privacy = 2
      when 'unlisted'
        pl.privacy = 1
      else
        pl.privacy = 0
      end
    end
    pl.content << Moped::BSON::ObjectId(params[:cwid]) if !params[:cwid].blank?
    if pl.save(:validate => false)
      render json:{status:'suc',title:"<a href='/play_lists/#{pl.id}'>#{pl.title}</a>",id:pl.id}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return true
    end
  end
  def bar_request_save_as
    if current_user.nil? or !Moped::BSON::ObjectId.legal?(params[:playlist_id])
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    render json:{status:'suc',html:render_to_string(file:'application/_playlist_bar_save',locals:{playlist_id:params[:playlist_id]},:layout=>false, :formats=>[:html])}
    return true
  end
  def bar_playlist_save_as
    if current_user.nil? or !Moped::BSON::ObjectId.legal?(params[:playlist_id])
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if params[:title].blank?
      render json:{status:'blank',reason:'请重复检查您的课件锦囊标题。'}
      return false
    end
    pl = PlayList.find_or_create_by(user_id:current_user.id,title:params[:title])
    pl.desc = params[:description] if !params[:description].blank?
    pl.content = PlayList.find(params[:playlist_id]).content
    if pl.save(:validate => false)
      render json:{status:'suc',new_playlist_id:pl.id}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def name_beautify(name)
    '_'==name[0] ? name[1..-1] : name
  end
  def dz_avatar_url(uid,email,size=:normal)
    return "http://uc.#{Setting.ktv_domain}/avatar.php?uid=#{uid}&email=#{Digest::MD5.hexdigest(email)}&size=#{size}"
  end
  def bar_request_update_bar
    if current_user.nil? or !Moped::BSON::ObjectId.legal?(params[:playlist_id])
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    pl = PlayList.find(params[:playlist_id])
    if !pl.nil?
      render json:{status:'suc',
        count:pl.content.size,title:pl.title,user_id:pl.user_id,
        user_name:name_beautify(User.get_name(pl.user_id)),
        user_src:dz_avatar_url(User.get_uid(pl.user_id),User.get_email(pl.user_id),:small),
        ol:render_to_string(file:'application/_bar_ol',locals:{coursewares:Courseware.eager_load(pl.content),playlist_id:pl.id},:layout=>false, :formats=>[:html]),
        bar_menu:render_to_string(file:'application/_bar_menu',locals:{playlist_id:pl.id,playlist_undestroyable:pl.undestroyable,playlist_title:pl.title},:layout=>false, :formats=>[:html])}
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  ### playlist end 
  def get_share_panel
      render file:'coursewares/_share_to',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
      return false
    # if current_user.nil?
    #   # render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
    # else
    #   render file:'coursewares/_share_to',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
    # end
  end
  def get_share_partial
    if params[:type] == 'embed'
        render file:'coursewares/_share_panel_embed',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
    elsif params[:type] == 'email'
        render file:'coursewares/_share_panel_email',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
    end
  end
  def ajax_send_email
      json = {status:'suc',cw_id:params[:cw_id],to:params[:recipients],msg:params[:message]}
      
      ##TODO   send mail to recipient
      cw_event_add_action("邮件分享",'Courseware',params[:cw_id],true)
      render json:json
  end
  def flag_cw
    begin
        fr = FlagRecord.new
        fr.cwid = params[:cw_id]
        fr.user_id = params[:user_id]
        fr.layer = params[:layer]
        fr.reason_id = params[:reason]
        fr.atype = 0
        params[:form].each do |k,v| 
            if v['name'] == 'flage_page'
                fr.flag_page  = v['value'].to_i
            end
            if v['name'] == 'flag_protected_group'
            fr.flag_protected_group = v['value']
            end
            if v['name'] == 'flag_desc'
                fr.flag_desc = v['value']
            end
        end
        cw_event_add_action("举报课件",'Courseware',params[:cw_id],true)
        fr.save(:validate=>false)
        json = {status:'suc'}
    rescue =>e
        cw_event_add_action("举报课件",'Courseware',params[:cw_id],false)
        json = {status:'failed'}
    end
    render json:json
  end
  def get_dynamic_dingcai
     cw = Courseware.find(params[:cw_id])
     has = cw.disliked_count+cw.thanked_count
     if has !=0
         dp = (cw.thanked_count * 1.0 / ((cw.disliked_count+cw.thanked_count) *1.0 )) * 100
         cp = (cw.disliked_count*1.0 / ((cw.disliked_count+cw.thanked_count)*1.0))*100
         json = {has:has,dingpercent:dp,caipercent:cp,d:cw.thanked_count,c:cw.disliked_count}
         render json:json
     else
       render json:{has:0}
     end
  end
  def comment_action
    atype = params[:atype]
    ct = Comment.find(params[:cid])
    cw = Courseware.find(ct.commentable_id)
    us = User.find(ct.user_id)
    if atype == "vote-up" 
        if  current_user.id !=ct.user_id and !ct.voteup_user_ids.include?(current_user.id) and !ct.votedown_user_ids.include?(current_user.id) 
            ct.update_attribute(:voteup,ct.voteup+1)
            ct.update_attribute(:voteup_user_ids,ct.voteup_user_ids << current_user.id)
            cw_event_add_action("评论顶",'Comment',ct.id,true)
            json = {status:'suc',up:ct.voteup,down:ct.votedown,cc:ct.voteup-ct.votedown}
        else
            cw_event_add_action("评论顶",'Comment',ct.id,false)
            if current_user.id == ct.user_id
                reason = '您顶的您自己！'
            elsif ct.voteup_user_ids.include?(current_user.id)
                reason = '您已经顶过了'
            elsif ct.votedown_user_ids.include?(current_user.id)
                reason = '您已经踩过了'
            else
                reason = 'I don\'t know why'
            end
            json = {status:'failed',reason:reason,up:ct.voteup,down:ct.votedown,cc:ct.voteup-ct.votedown}
        end
        render json:json
    elsif atype == "vote-down"
        if current_user.id !=ct.user_id and !ct.voteup_user_ids.include?(current_user.id) and !ct.votedown_user_ids.include?(current_user.id) 
            ct.update_attribute(:votedown,ct.votedown+1)
            ct.update_attribute(:votedown_user_ids,ct.votedown_user_ids << current_user.id)
            cw_event_add_action("评论踩",'Comment',ct.id,true)
            json = {status:'suc',up:ct.voteup,down:ct.votedown,cc:ct.voteup-ct.votedown}
        else
            cw_event_add_action("评论踩",'Comment',ct.id,false)
            if current_user.id == ct.user_id
                reason = '您踩的您自己！'
            elsif ct.voteup_user_ids.include?(current_user.id)
                reason = '您已经顶过了'
            elsif ct.votedown_user_ids.include?(current_user.id)
                reason = '您已经踩过了'
            else
                reason = 'I don\'t know why'
            end
            json = {status:'failed',reason:reason,up:ct.voteup,down:ct.votedown,cc:ct.voteup-ct.votedown}
        end
        render json:json
    elsif atype == 'reply'
        comment = Comment.new
        comment.replied_to_comment_id = ct.id
        render file:'coursewares/_ct2ct_new',locals:{comment:comment,parent:ct.id,cw:cw.id},layout:false
    elsif atype == 'share'
        render file:'coursewares/_comment_share',locals:{comment:ct,cw:cw},layout:false
    elsif atype == 'remove'
        if ct.user_id ==current_user.id or us.admin_type == User::SUP_ADMIN or us.admin_type == User::SUB_ADMIN
            ct.deletor_id = current_user.id
            ct.deleted_at = Time.now
            ct.save(:validate=>false)
            cw_event_add_action("评论删除",'Comment',ct.id,true)
            json = {status:'suc'}
            render json:json
            return true
        end
        cw_event_add_action("评论删除",'Comment',ct.id,false)
        json = {status:'failed'}
        render json:json
        return false
    elsif atype == 'flag'
        begin
            if !(ff = FlagRecord.where(cwid:ct.id).first).nil? and ff.atype == 1
                ff.update_attribute(:times,ff.times+1)
                json = {status:'suc'}
                render json:json 
                return false
            end 
            fr = FlagRecord.new
            fr.cwid = ct.id
            fr.user_id = params[:user_id]
            fr.atype = 1
            fr.save(:validate=>false)
            cw_event_add_action("评论举报",'Comment',ct.id,true)
            json = {status:'suc'}
        rescue =>e
            cw_event_add_action("评论举报",'Comment',ct.id,false)
            json = {status:'failed'}
        end
        render json:json        
    elsif atype == 'show-parent'
        cw_event_add_action("查看父评论",'Comment',ct.id,true)
        parent = Comment.find(ct.replied_to_comment_id)
        if !parent.nil?
            render file:'/coursewares/_cw_comment',locals:{comment:parent,data_score:0},layout:false
        end
    elsif atype == 'unblock'
    elsif atype == 'block'        
    end
  end

  def get_sorted_playlist
    uplist = PlayList.where(:user_id => current_user.id,:undestroyable=>false)
    case params[:sort]
    when 'vm-sort-newest'
        uplist = uplist.desc('created_at')
    when 'vm-sort-oldest'
        uplist = uplist.asc('created_at')
    when 'vm-sort-az'
        uplist = uplist.asc('title_en')        
    when 'vm-sort-za'
        uplist = uplist.desc('title_en')   
    end
    render file:'mine/_playlist_sort',locals:{uplist:uplist},layout:false
  end
  
  def add_to_playlist_by_url
      json_failed = {status:'failed',reason:'课件网址无效。'}
      if PlayList.where(id:params[:playlist_id]).first.nil?
        render json:{status:'failed',reason:'请先保存课件锦囊！'}
        return false
      end
      unless (params[:url] =~ URI::regexp).nil?
        pl = PlayList.find(params[:playlist_id])
        url = URI.parse(URI.encode(params[:url]))
        path = url.path
        path = path.split('/coursewares/')
        if path.nil?
            render json:json_failed
            return false
        end
        if (id = path[1]).nil?
            render json:json_failed
            return false
        end
        if !Moped::BSON::ObjectId.legal?(id)
            render json:json_failed
            return false
        end
        cw = Courseware.find(id)
        if pl.content.include?(cw.id)
            render json:{status:'failed',reason:'该课件锦囊里已经有该课件。'}
            return false
        end
        if cw.nil?
            render json:json_failed
            return false
        end
        add = pl.add_one_thing(cw.id)
        if add
             render json:{status:'suc',
                    list:render_to_string(:file=>"play_lists/_list.html.erb",:locals=>{content:pl.content,cwid:cw,index:(pl.content.count-1),annotation:pl.annotation,user_id:pl.user_id},:layout=>nil, :formats=>[:html])}
        else
          render json:{status:'failed',reason:'该课件已经存在该课件锦囊！'}
        end
      else
          render json:json_failed
          return false
      end
  end
  
  
  def add_to_playlist_by_id
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    pl = PlayList.find(params[:pid])
    legal = true
    add = true
    params[:cwid].to_a.each do |cwid|
      if !Moped::BSON::ObjectId.legal?(cwid)
        legal = false
        next
      end
      cw = Courseware.find(cwid)
      if pl.content.include?(cw.id)
        add = false
        next
      end
      if cw.nil?
        next
      end
      if params[:on_top].blank?
        add = pl.add_one_thing(cw.id)
      else
        add = pl.add_one_thing(cw.id,true)
      end
      cw_event_add_action("添加收藏",'Courseware',cw.id,true)
    end
    if params[:cwid].to_a.size > 1
      suc = 'suc'
    elsif params[:cwid].to_a.size == 1
      suc = 'onesuc'
    end
    if add and params[:cwid].to_a.size == 1
      render json:{status:suc,title:"<a href='/play_lists/#{pl.id}'>#{pl.title}</a>",playlist_id:pl.id,annotation:pl.annotation[pl.content.index(Moped::BSON::ObjectId(params[:cwid][0]))]}
      return true
    end
    if add
         render json:{status:suc,title:"<a href='/play_lists/#{pl.id}'>#{pl.title}</a>",playlist_id:pl.id}
         return true
    else
      if !legal
        render json:{status:'failed',reason:'您导入的内容稍后阅读无法接受！'}
      else
        render json:{status:'failed',reason:'该课件已经存在该课件锦囊！'}
      end
      return false
    end
  end
  def remove_ding_array
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    result = Array.new
    re = false
    params[:cwid].to_a.each_with_index do |cwid,index|
      cw = Courseware.find(cwid)
      result[index] = current_user.thank_courseware(cw)
    end
    result.map{|x| re = re or x}
    if !re
      render json:{status:'suc'}
    else
      render json:{status:'failed',reason:'该课件不存在于恁顶的课件中！'}
    end
  end
  
  def create_and_add_to_by_id
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    title = params[:title]
    privacy = params[:is_private]
    pl = PlayList.locate(current_user.id,title)
    if pl.nil?
      pl = PlayList.new
    end
    pl.user_id = current_user.id
    pl.title = title
    pl.privacy = privacy
    pl.save(:validate => false)
    if params[:cwid].size == 1
      cwid = params[:cwid][0]
      if !Moped::BSON::ObjectId.legal?(cwid)
        render json:{status:'failed',reason:'您导入的内容稍后阅读无法接受！'}
        return false
      end
      cw = Courseware.where(id:cwid).first
      if cw.nil?
        render json:{status:'failed',reason:'该课件已经不存在！'}
        return false
      end
      if pl.content.include?(cw.id)
        render json:{status:'failed',reason:'该课件已经存在该课件锦囊！'}
        return false
      end
      add = pl.add_one_thing(cw.id)
      if add
        render json:{status:'onesuc',title:"<a href='/play_lists/#{pl.id}'>#{pl.title}</a>",playlist_id:pl.id}
      else
        render json:{status:'failed',reason:'该课件已经存在该课件锦囊！'}
      end
    elsif params[:cwid].count > 1
      params[:pid] = pl.id
      add_to_playlist_by_id
    else
      render json:{status:'failed',reason:'未知错误，我们已经记录！'}
    end
  end
  def save_note_for_one_cw
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if !Moped::BSON::ObjectId.legal?(params[:cwid][0])
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    pl = PlayList.locate(current_user.id,params[:title])
    index = pl.content.index(Moped::BSON::ObjectId(params[:cwid][0]))
    if index
      pl.annotation[index] = params[:note].to_s
    end
    if pl.save(:validate=>false)
      render json:{status:'suc',title:"<a href='/play_lists/#{pl.id}'>#{pl.title}</a>"}
    else
      render json:{status:'failed',reason:'该课件并不存在于该课件锦囊！'}
    end
  end
  def add_to_read_later
     if current_user.nil?
         render json:{status:'failed',reason:'您尚未登录！'}
         return false
     end
     if !Moped::BSON::ObjectId.legal?(params[:cwid])
         render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
         return false
     end
     if params[:type] == 'addto'
         addto  = PlayList.add_to_read_later(current_user.id,params[:cwid])
     elsif params[:type] == 'remove'
         addto = PlayList.remove_from_read_later(current_user.id,params[:cwid])
     end
     if addto
         render json:{status:'suc',playlist_id:addto}
     else
         render json:{status:'failed',reason:'该课件已经存在于稍后阅读。'}
     end
  end
  
  def bar_update_content_in_playlist
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if params[:content_string].nil?
      render json:{status:'nil'}
      return false
    end
    params[:content_string].to_a.map! do |x|  
      if Moped::BSON::ObjectId.legal?(x) 
         x = Moped::BSON::ObjectId(x)
      else
        render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
        return false
      end
    end
    pl = PlayList.find(params[:pid])
    if pl.title == '历史记录'
      render json:{status:'suc'}
      return true
    end
    if pl.user_id != current_user.id
      render json:{status:'saveas'}
      return false
    end
    annotation = []
    params[:content_string].to_a.each_with_index do |cw,index|
      if (inornot = pl.content.index(cw))
        if !pl.annotation[inornot].blank?
          annotation[index] = pl.annotation[inornot]  #对应位置的 Annotation
        end
      end
    end
    pl.content = params[:content_string].to_a
    
    if pl.save(:validate => false)
      render json:{status:'suc'}
      return false
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def bar_undo_delete
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end    
    if !Moped::BSON::ObjectId.legal?(params[:pid])
      render json:{status:'nil'}
      return false
    end
    pl = PlayList.find(params[:pid])
    if pl.user_id != current_user.id
      render json:{status:'saveas'}
      return false
    end
    if pl.content_delete_cache.blank?
      render json:{status:'failed',reason:'Nothing to undo.'}
      return false
    end
    pl.content << pl.content_delete_cache
    pl.content_delete_cache = nil
    if pl.save(:validate => false )
      render json:{status:'suc',
        li:render_to_string(file:'application/_bar_ol',locals:{coursewares:Courseware.eager_load([pl.content[-1]]),playlist_id:pl.id},:layout=>false, :formats=>[:html])}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def summonQL
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    render json:{status:'suc',html:render_to_string(file:'application/_playlist_bar',locals:{playlist_id:params[:playlist_id],bar_max:params[:bar_max]},:layout=>false, :formats=>[:html])}
    return true
  end
  def bar_request_playlists
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    render json:{status:'suc',html:render_to_string(file:'application/_bar_playlists_list',locals:{playlists:PlayList.where(user_id:current_user.id).desc(:undestroyable).asc(:title_en)},:layout=>false, :formats=>[:html])}
    return true
  end
  def bar_delete_one_content
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if !Moped::BSON::ObjectId.legal?(params[:kid]) and !Moped::BSON::ObjectId.legal?(params[:pid])
      render json:{status:'nil'}
      return false
    end
    pl = PlayList.find(params[:pid])
    if pl.user_id != current_user.id
      render json:{status:'saveas'}
      return false
    end
    if (inornot = pl.content.index(Moped::BSON::ObjectId(params[:kid])))
      if !pl.annotation[inornot].blank?
        pl.annotation.delete_at(inornot)
      end
      pl.content.delete(Moped::BSON::ObjectId(params[:kid]))
      pl.content_delete_cache =Moped::BSON::ObjectId(params[:kid])
    end
    if pl.save(:validate => false )
      render json:{status:'suc'}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def add_to_read_later_array
    if current_user.nil?
        render json:{status:'failed',reason:'您尚未登录！'}
        return false
    end
    legal = true
    addto = true
    params[:cwid].to_a.each  do |cwid|
        if !Moped::BSON::ObjectId.legal?(cwid)
          legal = false
          next
        end
        if params[:type] == 'addto'
            addto  = PlayList.add_to_read_later(current_user.id,cwid)
        elsif params[:type] == 'remove'
            addto = PlayList.remove_from_read_later(current_user.id,cwid)
        end
    end

    if addto
        render json:{status:'suc',playlist_id:addto}
    else
      if !legal
        render json:{status:'failed',reason:'您导入的内容稍后阅读无法接受！'}
      elsif legal and params[:type] == 'addto'
        render json:{status:'failed',reason:'该课件已经存在于稍后阅读。'}
      elsif legal and params[:type] == 'remove'
        render json:{status:'failed',reason:'该课件已经不存在于稍后阅读。'}
      end
    end
  end
  def add_to_favorites_array
    if current_user.nil?
        render json:{status:'failed',reason:'您尚未登录！'}
        return false
    end
    legal = true
    addto = true
    params[:cwid].to_a.each  do |cwid|
        if !Moped::BSON::ObjectId.legal?(cwid)
          legal = false
          next
        end
        if params[:type] == 'addto'
            addto  = PlayList.add_to_read_later(current_user.id,cwid,'收藏')
        elsif params[:type] == 'remove'
            addto = PlayList.remove_from_read_later(current_user.id,cwid,'收藏')
        end
    end
    
    if addto
        render json:{status:'suc',playlist_id:addto}
    else
      if !legal
        render json:{status:'failed',reason:'您导入的内容收藏夹无法接受！'}
      elsif legal and params[:type] == 'addto'
        render json:{status:'failed',reason:'该课件已经存在于收藏夹。'}
      elsif legal and params[:type] == 'remove'
        render json:{status:'failed',reason:'该课件已经不存在于收藏夹。'}
      end
    end
  end
  def get_playlist_share
      url = "http://#{Setting.ktv_sub.nil? ? 'www' : Setting.ktv_sub}.kejian#{$psvr_really_development ? '.lvh.me' : '.tv'}/play_lists/#{params[:playlist_id]}"
      render file:'play_lists/_playlist_share',locals:{url:url,title:params[:title]},layout:false
  end
  def like_playlist
    return false if current_user.nil?
    pl = PlayList.find(params[:pid])
    if params[:type] == 'like'
      like = current_user.like_playlist(pl)
      if like
        aim = 'like'
      else
        aim = 'de_like'
      end
    elsif params[:type] == 'dislike'
      dislike = pl.disliked_by_user(current_user)
      if dislike
        aim = 'dislike'
      else
        aim = 'de_dislike'
      end
    end
    has = pl.vote_up + pl.vote_down
    if has == 0
      render json:{status:'suc',has:0,aim:aim}
    else
      plike = ((pl.vote_up * 1.0 )/ (has*1.0))*100
      pdislike = ((pl.vote_down * 1.0 )/ (has*1.0))*100
      render json:{status:'suc',aim:aim,has:has,like:pl.vote_up,dislike:pl.vote_down,plike:plike,pdislike:pdislike}
    end      
  end
  def get_addto_menu
    if current_user.nil?
      render json:{status:'failed',reason:'尚未登录'}
      return false
    end
    render json:{status:'suc',
      html:render_to_string(:file=>"mine/_addto_menu.html.erb",
                                    :locals=>{user:current_user,playlist_readlater:PlayList.locate(current_user.id,'稍后阅读'),playlist_favorite:PlayList.locate(current_user.id,'收藏')},
                                    :layout=>nil, :formats=>[:html]) }
  end
  def save_page_to_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if request.env['HTTP_REFERER'].blank?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if URI.parse(request.env['HTTP_REFERER']).path != '/embed/'+params[:cwid]
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if !(Moped::BSON::ObjectId.legal?(params[:cwid]))
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    if PlayList.add_to_history(current_user.id,params[:cwid],params[:page].to_i)
      render json:{status:'suc',page:params[:page].to_i}
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
    end
    return true
  end
  def pause_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    PlayList.on_off_history(current_user.id,params[:switch])
    render json:{status:'suc'}
    return true
  end
  
  def remove_one_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    result = true
    params[:time].to_a.each_with_index do |tt,index|
      cwid = params[:cwid][index]
      result = PlayList.remove_one_history(current_user.id,cwid,tt.to_i)
    end
    if result
      render json:{status:'suc'}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def clear_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    result = PlayList.clear_history(current_user.id)
    if result
      render json:{status:'suc'}
      return true
    else
      render json:{status:'failed',reason:'无法清除历史记录。'}
      return false
    end
  end
  def pause_search_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    SearchHistory.on_off_history(current_user.id,params[:switch])
    render json:{status:'suc'}
    return true
  end
  def remove_one_search_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    result = true
    params[:cwid].to_a.each_with_index do |shid,index|
      result =  SearchHistory.remove_one_search_history(shid)
    end
    if result
      render json:{status:'suc'}
      return true
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end   
  end

  def clear_search_history
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    result = SearchHistory.clear_history(current_user.id)
    if result
      render json:{status:'suc'}
      return true
    else
      render json:{status:'failed',reason:'无法清除搜素记录。'}
      return false
    end
  end
  def delete_upload
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！',arr:[]}
      return false
    end
    legal = true
    null  = true
    arr = []
    params[:cwid].to_a.each do |id|
      if !Moped::BSON::ObjectId.legal?(id)
        legal = false
        next
      end
      if (cw = Courseware.where(id:id).first).nil?
        null  = false
        next
      end
      if cw.uploader_id == current_user.id
        cw.ua(:deleted,1)
        arr << id
      end
    end
    if !legal or !null
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。',arr:arr}
      return false
    end
    render json:{status:'suc'}
    return true
  end
  
  def setting_cw_license
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！',arr:[]}
      return false
    end
    legal = true
    null  = true
    arr = []
    params[:cwid].to_a.each do |id|
      if !Moped::BSON::ObjectId.legal?(id)
        legal = false
        next
      end
      if (cw = Courseware.where(id:id).first).nil?
        null  = false
        next
      end
      if cw.uploader_id == current_user.id
        result = true
        if params[:type] == 'std'
          result = cw.change2std
        elsif params[:type] == 'cc'
          result = cw.change2cc
        end
        if result
          arr << id
        end
      end
    end
    if !legal or !null
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。',arr:arr}
      return false
    end
    render json:{status:'suc'}
    return true
  end
  
  def enable_beauty_view
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if params[:tf] =='true'
      current_user.ua(:enable_beauty_view,true)
    elsif params[:tf] == 'false'
      current_user.ua(:enable_beauty_view,false)
    end
    render json:{status:'suc'}
  end
  def set_privacy
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！',arr:[]}
      return false
    end
    legal = true
    null  = true
    arr = []
    params[:cwid].to_a.each do |id|
      if !Moped::BSON::ObjectId.legal?(id)
        legal = false
        next
      end
      if (cw = Courseware.where(id:id)).nil?
        null  = false
        next
      end
      if cw.uploader_id == current_user.id
        result = cw.set_privacy(params[:type])
        if result
          arr << id
        end
      end
    end
    if !legal or !null
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。',arr:arr}
      return false
    end
    render json:{status:'suc'}
    return true
  end
  def update_widget_sort
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    if (params[:right].to_a + params[:left].to_a).size > 4
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。！'}
      return false
    end
    # !(params[:left].kind_of?(Array) and params[:right].kind_of?(Array))
    # and (params[:right]+ params[:left]).sort ==['0','1','2','3'])
    sort  = {left:params[:left].to_a,right:params[:right].to_a}
    if current_user.ua(:widget_sort,sort)
      render json:{status:'suc'}
      return false
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
  end
  def request_widget
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    wid = nil
    case params[:widget_type]
    when 'video'
      @coursewares = Courseware.nondeleted.where(uploader_id:current_user.id).desc('created_at').limit(4)
      @readlater = PlayList.where(user_id:current_user.id,undestroyable:true,title:'稍后阅读').first
      wid = '0'
    when 'comments'
      wid = '1'
    when 'analytics'
      wid = '2'
    when 'promos'
      wid = '3'
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    
    if current_user.widget_sort.values.flatten.include?(wid) or wid.nil?
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    if wid == '0'
      render json:{widget:render_to_string(file:'mine/_dashboard_widget_'+wid,locals:{coursewares:@coursewares},collections:@readlater,:layout=>false, :formats=>[:html])}
    else
      render json:{widget:render_to_string(file:'mine/_dashboard_widget_'+wid,:layout=>false, :formats=>[:html])}
    end
    return true
  end
  def update_widget_property
    if current_user.nil?
      render json:{status:'failed',reason:'您尚未登录！'}
      return false
    end
    wid = nil
    case params[:wid]
    when 'kejian'
      wid = '0'
      @coursewares = Courseware.filter_by_privacy(current_user.id,params[:filter].to_s,params[:num].to_i)
      @readlater = PlayList.where(user_id:current_user.id,undestroyable:true,title:'稍后阅读').first
    when 'comments'
      wid = '1'
    else
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    if (!current_user.widget_sort.values.flatten.include?(wid)) or wid.nil?
      render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
      return false
    end
    
    if wid == '0'
      if current_user.update_widget_kejian(params[:title].to_s,params[:num].to_s,params[:filter].to_s.strip)
        render json:{widget_html:render_to_string(file:'mine/_dashboard_widget_'+wid,locals:{coursewares:@coursewares},collections:@readlater,:layout=>false, :formats=>[:html])}
        return true
      else
        render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
        return false
      end
    else
      if current_user.update_widget_commment(params[:title].to_s,params[:num].to_s)
        render json:{widget_html:render_to_string(file:'mine/_dashboard_widget_'+wid,:layout=>false, :formats=>[:html])}
        return true
      else
        render json:{status:'failed',reason:'系统无法完成请求，请稍后重试。'}
        return false
      end
    end    
    
  end
end
