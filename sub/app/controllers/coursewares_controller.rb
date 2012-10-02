# -*- encoding : utf-8 -*-
class CoursewaresController < ApplicationController
  before_filter :authenticate_user!, :only => [:new,:create,:edit,:update,:destroy,:thank,:download]
  before_filter :find_item,:only => [:show,:embed,:download,:edit,:update,:destroy,:thank]
  before_filter :authenticate_user_ownership!, :only => [:update,:destroy]
  
  def latest
    @seo[:title] = '最新课件'
    render "latest"
  end
  def hot
    @seo[:title] = '最热课件'
    render "latest"
  end
  def videos
    @seo[:title] = '课堂录像'
  end
  def books
    @seo[:title] = '电子书'
  end
  
  def index
    respond_to do |format|
      format.json{
        pagination_get_ready
        @coursewares = Courseware.nondeleted.normal
        deal_with_params!
        pagination_over(@coursewares.count)
        @coursewares = @coursewares.paginate(:page => @page, :per_page => @per_page)
        render "index",:layout=>false
      }
      format.html{
        render "index"
      }
    end
  end
  def mine
    @seo[:title] = '我关注的'
    respond_to do |format|
      format.json{
        pagination_get_ready
        @coursewares = Courseware.any_of({:user_id.in => current_user.following_ids},
                        {:topic.in => current_user.followed_topic_ids}).nondeleted.normal
        deal_with_params!
        pagination_over(@coursewares.count)
        @coursewares = @coursewares.paginate(:page => @page, :per_page => @per_page)
        render "index"
      }
      format.html{
        render "mine"
      }
    end
  end
  def deal_with_params!
    @coursewares = @coursewares.where(:is_thin=>false) if '1'==params['onlyForCommodity']
    @coursewares = @coursewares.where(:slides_count.gt=>50) if '2'==params['queryScope']
    if '1'==params['queryOrder']
      @coursewares = @coursewares.desc('created_at')
    elsif '2'==params['queryOrder']
      @coursewares = @coursewares.desc('views_count')
    end
    @coursewares = @coursewares.where(:user_id=>params[:user_id]) if params[:user_id]
    @coursewares = @coursewares.where(:topics=>params[:topic]) if params[:topic]
  end
  def thank
    current_user.inc(:thank_coursewares_count,1)
    @courseware.user.inc(:thanked_coursewares_count,1)
    @courseware.inc(:thanked_count,1)
    current_user.thank_courseware(@courseware)
    render :text => "1"
  end
  def new_youku
    @seo[:title] = '导入视频网站视频'
    @courseware = Courseware.new
  end
  def new_emule
    @seo[:title] = '导入原始下载地址'
  end
  def new_sina
    @seo[:title] = '导入外站资源链接'
  end
  def new
    @seo[:title] = '上传课件'
    @c = Course.where(fid:params[:psvr_f].to_i).first
    if @c
      @teachers = @c.teachings.collect(&:teacher).uniq
    else
      @teachers = []
    end
    @courseware = Courseware.new
    @courseware.version_date[@courseware.version.to_s] = Time.now.strftime("%Y年%m月%d日")
    prepare_s3
  end
  def embed
    @courseware.view! unless @courseware.id.to_s==Setting.ktv_courseware_id
    version_issues_deal!
    respond_to do |format|
      format.html
      format.js
    end
  end
  def show
    respond_to do |format|
      format.html{
        @seo[:title] = @courseware.title
        @comment = @courseware.comments.build
        @note = Note.new
        @note.courseware_id = @courseware.id
        @note.page = 0
        version_issues_deal!
        render "show"
      }
      format.json{
        render json:@courseware
      }
    end
  end
  def version_issues_deal!
    @courseware_real_version = @courseware.version
    if params[:revision_id].present?
      converted_revision_id = params[:revision_id].to_i - 1
      if converted_revision_id >= 0 and converted_revision_id <= @courseware_real_version
        @courseware.version = converted_revision_id
        @courseware.title += " (第#{converted_revision_id + 1}版)"
      end
    end
  end
  def edit
    @seo[:title] = '编辑课件'
    prepare_s3
  end
  def destroy
    @courseware.soft_delete
    redirect_to '/',:notice=>'已成功删除'
  end
  def download
    # 由于积分和防批量下载的功能没弄好，先别开放下载
    render text:'开发中，sorry'
    return
    downurl = ''
    if @courseware.have_pw and params[:pw].blank?
      render 'download',:layout => 'application_for_devise'
      return
    elsif @courseware.have_pw and Digest::MD5.hexdigest(params[:pw])!=@courseware.pw
      @pw_error = '密码错误'
      render 'download',:layout => 'application_for_devise'
      return
    end
    @courseware.inc(:downloads_count,1)
    if @courseware.xunlei_url.present?
      downurl = @courseware.xunlei_url
    else
      resource = "#{@courseware.id}#{@courseware.revision}.zip"
      expires = 2.minutes.since.to_i
      signature = Sndacs::Signature.generate_temporary_url_signature(:bucket => 'ktv-down',:resource => resource,:secret_access_key => Setting.snda_key,:expires_at => expires)
      downurl = "http://storage-huabei-1.sdcloud.cn/ktv-down/#{resource}?SNDAAccessKeyId=#{Setting.snda_id}&Expires=#{expires}&Signature=#{signature}"
# something like
# http://storage-huabei-1.sdcloud.cn/ktv-down/1.zip?SNDAAccessKeyId=7HDL3HVT04F5RF6BRW90BJUXH&Expires=1342108303&Signature=Bwyy2k9lPqrmFB4%2BBpBV8q%2FDnzI%3D
    end
    redirect_to downurl
  end
protected
  def find_item
    @courseware = Courseware.where(:_id => params[:id]).first
    unless @courseware.present?
      render_404
      return false
    end
  end
  def prepare_s3
    @uptime = Time.now.to_i
    policy = {
      'save-key' =>  "/#{current_user.id}/#{@uptime}.pdf",
      expiration: "#{1.hour.since.to_i}",
      bucket: 'ktv-up',
      'allow-file-type' =>  'pdf,djvu,ppt,pptx,doc,docx,zip,rar,7z',
      'content-length-range' =>  '0,199000000',
    }.to_json
    policy = Base64.encode64(policy).split("\n").join('')
    @config = {
      policy: policy,
      signature: Digest::MD5.hexdigest(policy+'&'+'Vv0WpPhlztxkPn7c9F3x3S8zgRE=')
    }    
  end
  def authenticate_user_ownership!
    unless current_user.id==@courseware.user_id or current_user.id==@courseware.uploader_id
      render text:'这不是你的课件.', status: 401
      return false
    end
  end
end
