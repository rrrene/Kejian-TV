# -*- encoding : utf-8 -*-
class AjaxController < ApplicationController
  before_filter :authenticate_user!, :except => [:checkUsername,:checkEmailAjax,:xl_req_get_method_vod,:logincheck,:seg,:star_refresh]
  def check_fangwendizhi
    ff=User.fangwendizhize(params[:f])
    not_used = true
    not_used = (!User::FORBIDDEN_FANGWENDIZHI.include?(ff)) if not_used
    not_used = ('0'==UCenter::User.update_fangwendizhi(nil,{will_fire:false,fangwendizhi:ff})) if not_used
    render json:{ff:ff,not_used:not_used}
  end
  def watch_later
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
    # elsif !u.confirmed?
    #   if u.authorizations_count > 0
    #     render text:"此E-mail尚未激活，但关联了#{u.authorizations.collect{|au| Ktv::Consumers[au.provider][3]}}.join('、')账号，您可以先用它们登录然后设置邮箱"
    #   else
    #     render text:'此E-mail尚未激活，请点击邮件里的激活链接，或重发激活邮件'
    #   end
    # elsif u.encrypted_password.empty?
    #   if u.authorizations_count > 0
    #     render text:"此账号尚未设置密码，但关联了#{u.authorizations.collect{|au| Ktv::Consumers[au.provider][3]}}.join('、')账号，您可以先用它们登录然后设置密码"
    #   else
    #     render text:'此账号尚未设置密码，请点击邮件里的激活链接激活账户并设置密码'
    #   end
    else
      render text:'0'
    end
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
        more = "第#{:complete}页, 共#{cw.slides_count}页"
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
        cw_event_add_action("课件顶",'Courseware',courseware.id,true) if !result
        render file:'coursewares/_watch_like',locals:{cw_id:params[:cw_id]},layout:false  
      end
    elsif params[:type] == 'watch-unlike'
      if current_user.nil?
        render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
      else
        cw = Courseware.find(params[:cw_id])
        if !cw.disliked_user_ids.include?(current_user.id) and !cw.thanked_user_ids.include?(current_user.id)
          cw.update_attribute(:disliked_count,cw.disliked_count+1)
          cw.update_attribute(:disliked_user_ids,cw.disliked_user_ids << current_user.id)
          cw_event_add_action("课件踩",'Courseware',cw.id,true)
        end
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
    cw_event_add_action("添加收藏",'Courseware',cw.id,true)
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
    if params[:list_title].blank?
        json = {status:'failed',list_title:pl.title,id:pl.id.to_s,is_private:pl.privacy.to_s}
        render json:json
        return false
    end
    pl = PlayList.find_or_create_by(user_id:current_user.id,title:params[:list_title])
    pl.ua(:desc,params[:desc]) if !params[:desc].blank?
    pl.ua(:privacy,params[:is_private]) if !params[:is_private].blank?
    
    json = {status:'suc',list_title:pl.title,id:pl.id.to_s,is_private:pl.privacy.to_s}
    render json:json
  end
  ### playlist end 
  def get_share_panel
    if current_user.nil?
      render :text => "<div><a href='javascript:void(0)' class='like grey psvr_login_required'>登录</a>之后就可以踩了。</div>"
    else
      render file:'coursewares/_share_to',locals:{cw:Courseware.find(params[:cw_id])},layout:false  
    end
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
     dp = (cw.thanked_count * 1.0 / ((cw.disliked_count+cw.thanked_count) *1.0 )) * 100
     cp = (cw.disliked_count*1.0 / ((cw.disliked_count+cw.thanked_count)*1.0))*100
     
     json = {dingpercent:dp,caipercent:cp,d:cw.thanked_count,c:cw.disliked_count}
     render json:json
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
        if !BSON::ObjectId.legal?(id)
            render json:json_failed
            return false
        end
        if pl.content.include?(id)
            json_failed = {status:'failed',reason:'该课件锦囊里已经有该课件。'}
            render json:json_failed
            return false
        end
        cw = Courseware.find(id)
        if cw.nil?
            render json:json_failed
            return false
        end
        pl.add_one_thing(cw.id)
        
        render json:{status:'suc',
                    list:render_to_string(:file=>"play_lists/_list.html.erb",:locals=>{content:pl.content,cwid:cw.id,index:(pl.content.count-1),annotation:pl.annotation,user_id:pl.user_id},:layout=>nil, :formats=>[:html])}
      else
          render json:json_failed
          return false
      end
  end
  
  def add_to_read_later
     if current_user.nil?
         render json:{status:'failed',reason:'您尚未登陆！'}
         return false
     end
     if !BSON::ObjectId.legal?(params[:cwid])
         render json:{status:'failed',reason:'您导入的内容稍后阅读无啊接受！'}
         return false
     end
     if params[:type] == 'addto'
         addto  = PlayList.add_to_read_later(current_user.id,params[:cwid])
     elsif params[:type] == 'remove'
         addto = PlayList.remove_from_read_later(current_user.id,params[:cwid])
     end
     if addto
         render json:{status:'suc'}
     else
         render json:{status:'failed',reason:'该课件已经存在于稍后阅读。'}
     end
  end
  def get_playlist_share
      url = "http://#{Setting.ktv_sub.nil? ? 'www' : Setting.ktv_sub}.kejian#{$psvr_really_development ? '.lvh.me' : '.tv'}/play_lists/#{params[:playlist_id]}"
      render file:'play_lists/_playlist_share',locals:{url:url},layout:false
  end
end

