# -*- encoding : utf-8 -*-
class Courseware
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  include BaseModel
  # sort by this
  field :psvr_downready,:type=>Boolean,:default=>false
  field :score,:type=>Integer,:default=>0  
  @before_soft_delete = proc{
    if self.uploader_id_candidates.blank?
      true
    else
      self.uploader_id = self.uploader_id_candidates[0]
      Courseware.where(redirect_to_id:self.id,uploader_id:self.uploader_id,:id.ne => self.id).each do |x|
        x.uploader_id_candidates = []
        x.redirect_to_id = nil
        x.save(:validate=>false)
        self.uploader.inc(:coursewares_uploaded_count,-1)
        x.soft_delete
      end
      self.save(:validate=>false)
      false
    end
  }
  @after_soft_delete = proc{
    redis_search_index_destroy
    redis_search_psvr_was_delete!
    instance=self
    Tire.index(self.class.elastic_search_psvr_index_name) do
      remove instance
    end
  }
  FILE_INFO_TRANS = {
    'Little Endian,' => '小端序,',
    'Os: Windows, Version 5.1,' => '创作所用操作系统: Windows XP,',
    'Os: Windows, Version 6.1,' => '创作所用操作系统: Windows 7,',
    ', Code page:' => ', 代码页:',
    ', Title:' => ', 标题:',
    ', Author:' => ', 文件用户:',
    ', Template:' => ', 所用模板:',
    ', Last Saved By:' => ', 最后保存用户:',
    ', Revision Number:' => ', 修改次数:',
    ', Number of Characters:' => ', 字符数:',
    ', Number of Pages:' => ', 页数:',
    ', Security:' => ', 文档安全级别:',
  }
  def cw_pages
    Page.where(courseware_id:self.id.to_s)
  end
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :user;'课件的作者'
    when :slides_count;'幻灯片片数'
    when :title;'课件标题'
    when :title_en;'课件英文标题'
    when :title_pinyin;'课件拼音标题'
    when :desc;'课件描述'
    when :title_series_concerned;'标题(长)'
    when :sort1;'课件角色类型'
    when :sort2;'课件文件类型'
    when :sort_humanized;'课件类型'
    when :slug;'课件的友好资源标识号'
    when :xunlei_link;'迅雷播放特权地址'
    when :fallback_playback_link;'视频后援地址'
    when :link_memo;'链接备注'
    else
      COMMON_HUMAN_ATTR_NAME[attr].present? ? COMMON_HUMAN_ATTR_NAME[attr] : attr.to_s
    end
  end
  STATE_SYM = {
    0 => :normal,
    1 => :waiting4downloading,
    2 => :waiting4transcoding,
    3 => :finalizing,
    4 => :dealing_with_kids,
    5 => :matched_third_party_content,
    6 => :auditing,
    -1 => :error,
    -2 => :uniq_error,
    -3 => :win_error
  }
  STATE_TEXT = {
    :normal => '已上线',
    :waiting4downloading => '正在读取文件',
    :waiting4transcoding => '正在转码',
    :finalizing => '正在完成最后的处理',
    :dealing_with_kids => '正在转码子文件',
    :matched_third_party_content => '与第三方内容匹配',
    :auditing => '审核中',
    :error => '您上传的文件已损坏',
    :uniq_error=>'您上传的文件已存在',
    :win_error=>'您的文件含密码或为只读'
  }
  
  scope :normal, where(:status.in => [0,7])
  scope :has_ktv_id,where(:ktvid.nin=>[nil,''])
  scope :non_redirect,where(:redirect_to_id => nil)
  scope :is_father,where(:is_children.ne=>true) #liber add,:injected_count.ne=>0
  def is_father?
    self.is_children!=true
  end
  scope :is_child,where(:is_children=>true)
  scope :abnormal, where(:status.lt => 0)
  scope :transcoding, where(:status.gt => 0)
  scope :waiting4downloading, where(:status => 1)
  scope :waiting4transcoding, where(:status => 2)
  scope :dealing_with_kids,where(:status => 4)
  scope :finalizing, where(:status => 3)
  
  SORT1STR = {
    'lecture_notes' => '讲义',
    'assignments' => '作业',
    'exams' => '试卷',
    'videos' => '课堂录像',
    'materials' => '资料/读物',
  }
  
  SORTSTR = {
    'xunlei' => '迅雷播放特权',
    'ppt' => '幻灯片',
    'pptx' => '幻灯片',
    'doc' => '文档资料',
    'docx' => '文档资料',
    'pdf' => '文档资料',
    'djvu' => '电子书',
    'webm'=> '原创视频',
    'youku'=> '优酷视频',
    'tudou'=> '土豆视频',
    'youtube'=> 'YouTube视频',
    'books' => '课本封皮',
    'zip' => '压缩包',
    'rar' => '压缩包',
    '7z' => '压缩包',
    'png' => '图片',
    'jpg' => '图片',
    'jpeg' => '图片'
  }
  SORTDOWNTYPES ={
    'ppt' => ['ppt','pdf'],
    'pptx' => ['pptx','pdf'],
    'doc' => ['doc','pdf'],
    'docx' => ['docx','pdf'],
    'pdf' => ['pdf'],
    'djvu' => [],
    'webm'=> [],
    'youku'=> [],
    'tudou'=> [],
    'youtube'=> [],
    'books' => [],
    'zip' => ['zip'],
    'rar' => ['rar'],
    '7z' => ['7z'],
    'png' => ['png'],
    'jpg' => ['jpg'],
    'jpeg' => ['jpeg'],
  }
  SORTDOWNFILENAMES ={
    'ppt' => ['ppt','pdf'],
    'pptx' => ['pptx','pdf'],
    'doc' => ['doc','pdf'],
    'docx' => ['docx','pdf'],
    'pdf' => ['#{self.ktvid}#{self.revision}.zip'],
    'djvu' => [],
    'webm'=> [],
    'youku'=> [],
    'tudou'=> [],
    'youtube'=> [],
    'books' => [],
    'zip' => ['#{self.ktvid}#{self.revision}.zip'],
    'rar' => ['rar'],
    '7z' => ['7z'],
    'png' => ['png'],
    'jpg' => ['jpg'],
    'jpeg' => ['jpeg'],
  }
  alias_method :as_json_before_psvr,:as_json
  def as_json(opts={})
    {id:self.id,status:self.status,status_str:STATE_TEXT[STATE_SYM[self.status]],wh_ratio:self.wh_ratio,thin:self.thin?}
  end
  def asynchronously_clean_me
    bad_ids = [self.id]
    self.user.inc(:coursewares_count,-1) if self.user
    self.uploader.inc(:coursewares_uploaded_count,-1) if self.uploader
    self.teachers.each do |x|
      Teacher.locate(x).inc(:coursewares_count,-1)
    end
    cw = Course.where(fid:self.course_fid).first
    cw.inc(:coursewares_count,-1) if cw
    dep = Department.where(fid:self.department_fid).first
    dep.inc(:coursewares_count,-1) if dep
    
    thanked = false
    User.where(:thanked_courseware_ids=>self.id).each do |u|
      u.inc(:thank_count,-1)
      thanked = true
    end
    self.uploader.inc(:thanked_count,-1) if thanked and self.uploader
    disliked = false
    self.disliked_user_ids.each do |x|
      u = User.where(id:x).first
      if u
        u.inc(:dislike_count,-1) 
        disliked = true
      end
    end
    self.uploader.inc(:disliked_count,-1) if disliked and self.uploader
    
    Util.bad_id_out_of!(User,:thanked_courseware_ids,bad_ids)
    Util.bad_id_out_of!(PlayList,:content,bad_ids)
    Util.del_propogate_to(Comment,:_id,self.comments.collect(&:id))
    if self.tree.present?
      self.get_children.each do |child|
        child
      end
    end
  end
  field :privacy, :type=>Integer, :default=>0
  field :public_time,:type=>Time,:default=>Time.now
  scope :no_privacy, where(:privacy => 0)
  PRIVACY_TYPE = {
    0 => '公开',    # 列表里面有
    1 => '不公开',   # 列表里没有，但是可以通过链接打开、分享
    2 => '私有'      # 私有就是私有
  }
  PRIVACY_EN = {
    'public' => '公开',    # 列表里面有
    'unlisted' => '不公开',   # 列表里没有，但是可以通过链接打开、分享
    'private' => '私有'      # 私有就是私有
  }
  
  def self.filter_by_privacy(uploader_user_id,query,limit=4)
    case query.strip
    when ''
      Courseware.nondeleted.is_father.where(uploader_id:uploader_user_id).desc('created_at').limit(limit)
    when 'is:public'
      Courseware.nondeleted.is_father.where(uploader_id:uploader_user_id,privacy:0).desc('created_at').limit(limit)
    when 'is:unlisted'
      Courseware.nondeleted.is_father.where(uploader_id:uploader_user_id,privacy:1).desc('created_at').limit(limit)
    when 'is:private'
      Courseware.nondeleted.is_father.where(uploader_id:uploader_user_id,privacy:2).desc('created_at').limit(limit)
    else
      Courseware.nondeleted.is_father.where(uploader_id:uploader_user_id,title:/#{query}/).desc('created_at').limit(limit)
    end
  end
  def set_privacy(type)
    re = true
    if type =='public'
      self.privacy = 0
      self.public_time = Time.now
      re = self.save(:validate => false)
    elsif type == 'unlisted'
      re = self.ua(:privacy,1)
    elsif type == 'private'
      re = self.ua(:privacy,2)
    end
    return re
  end
  field :subsite
  field :uid
  field :tid,:type=>Integer, :default => 0
  field :pid,:type=>Integer, :default => 0
  field :author # slug
  field :ktvid
  field :legacy_ibeike
  field :legacy_cnu
  field :have_pw,:type=>Boolean,:default=>false
  field :pw
  field :md5
  field :status
  field :sub_status,:type=>Integer,:default=>0 ## 0=>listed,1 => unlisted
  field :uploader_id
  field :uploader_id_candidates,:type=>Array,:default=>[]
  def uploader_ins
    User.find(self.uploader_id)
  end
  field :is_thin,:type => Boolean,:default => true
  field :title_short
  
  field :school_name
  field :school_id
  field :user_name
  field :user_id
  field :user_ids,:type => Array,:default=>[]
  field :topic
  field :topics
  field :topic_id
  field :department_fid
  def calculate_department_fid
    self.department_fid=self.course_ins.department_fid
  end
  field :course_fid
  def course_ins(alt=nil)
    alt=self.course_fid if !alt
    Course.where(fid:alt).first
  end
  def department_ins(alt=nil)
    alt=self.department_fid if !alt
    Department.where(fid:self.department_fid).first
  end
  field :teachers,:type=>Array,:default=>[]
  def teachers_ins
    Teacher.where(:name.in=>self.teachers)
  end
  #about compressed files
  field :tree,:type=>Hash,:default=>{}
  field :forest,:type=>Hash,:default=>{}
  field :father_id
  def father_ins
    Courseware.find(self.father_id)
  end
  field :child_rank,:type=>Integer, :default => 0
  field :is_children,:type => Boolean, :default => false
  field :where_am_i_in_this_family
  field :files_count, :type => Integer, :default => 1
  field :transcoding_count, :type => Integer, :default => 0
  field :injected_count,:type=>Integer,:default =>0
  #end of compressed files
  field :title
  field :title_en
  field :sort1,:default=>'lecture_notes'
  field :sort
  field :pdf_filename
  field :remote_filepath
  field :really_broken,:type=>Boolean,:default=>false
  field :really_remote
  field :really_localhost
  field :really_localpath
  field :dz_filepath
  field :fileinfo_raw #ex. CDF V2 Document, Little Endian, Os: Windows, Version 5.1, Code page: 936, Title: PowerPoint Presentation, Template: C:\Program Files\Microsoft Office\Templates\Presentation Designs\Capsules.pot, Last Saved By: lib, Revision Number: 290, Name of Creating Application: Microsoft PowerPoint, Total Editing Time: 3d+04:21:41, Last Saved Time/Date: Fri Mar 18 06:36:57 2011, Number of Words: 729
  field :fileinfo #ex. 复合文档格式2.0版本, 小端序, 共689页. 创作所用操作系统: Windows XP, 代码页: 936, 标题: C程序设计, 作者用户: 汪世伟, 所用模板: C:\Program Files\Microsoft Office\Templates\演示文稿设计\彩晕型模板.pot, 最后保存用户: MC SYSTEM, 修改次数: 1048, 创作所用软件: Microsoft PowerPoint, 创作累计花费人力时间: 15天1小时22分钟20秒, 创作开始于: 2000年09月21日 06:03:07, 创作结束于: 2011年06月06日 13:23:58, 字数: 77101. 
  field :filesort #ex. 复合文档格式2.0版本
  field :filesort_mundane
  field :words_count, :type => Integer, :default => 0; #ex. 77101
  field :human_time, :type => Integer, :default => 0; #ex. 77101321
  #analytics 
  field :milestone,:type=>Hash,:default => {} # type => [time,note,times]
  
  MILESTONE_TYPE = {
       0 => '来自 课件TV 搜索的首次推荐',
       1 => '来自相关课件的首次推荐',
       2 => '来自 外部 搜索的首次推荐',
       3 => '来自 外部 的首次分享',
       4 => '第一通过嵌入方式观看',
       5 => '第一次通过移动设备观看',
       6 => '第一次得到订阅者模块的推荐'
  }
  #license
  field :license,:type=>Integer,:default=>0
  LICENSE_TYPE={
    0=>'标准 课件TV 许可',
    1=>'知识共享 - 署名'
  }
  LICENSE_EN = {
    "all_rights_reserved" => "标准 课件TV 许可",
    "creative_commons" => "知识共享 - 署名"
  }
  LICENSE_EN_TO_I = {
    "all_rights_reserved" => 0,
    "creative_commons" => 1
  }
  def change2std
     if self.ua(:license,0)
       return true
     else
       return false
     end
  end
  def change2cc
    if self.ua(:license,1)
      return true
    else
      return false
    end
  end
  def human_time_human(opts={})
    return '' if 0==self.human_time
    ret = ChronicDuration.output(self.human_time, :format => :long)
    if opts[:very_short]
      ret = ret.split(' ')[0..3].join(' ')
    end
    return ret.gsub(' years','年').gsub(' year','年').gsub(' days','天').gsub(' day','天').gsub(' hours','小时').gsub(' hour','小时').gsub(' minutes','分钟').gsub(' minute','分钟').gsub(' seconds','秒').gsub(' second','秒').gsub(' ','')
  end
  field :started_at # ex. 2011年06月06日 13:23:58
  field :finished_at # ex. 2011年06月06日 13:23:58
  field :pinpicname
  field :pdf_size_note
  field :pdf_slide_processed
  field :filesize,:default=>0
  field :down_pdf_size,:default=>0
  field :desc
  field :slug
  # field :topic  #repeated
  field :real_width, :type => Integer, :default => 0
  field :real_height, :type => Integer, :default => 0
  field :width, :type => Integer, :default => 0
  field :height, :type => Integer, :default => 0
  field :slides_count, :type => Integer, :default => 0;
  def fix_pages
    working_dir = "/media/b/auxiliary/ftp/cw_fix_pages/#{self.id}"
    FileUtils.mkdir_p(working_dir)
    File.open("#{working_dir}/#{self.id}#{self.revision}.zip","wb") do |f|
      f.write $snda_ktv_down.objects.find("#{self.id}#{self.revision}.zip").content
    end
    #todo
  end
  field :gone_normal_at
  field :price,:type=>Integer,:default=>0
  field :thanked_count, :type => Integer, :default => 0
  field :disliked_count, :type => Integer, :default => 0
  field :add_to_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :views_count, :type => Integer, :default => 0
  field :downloads_count, :type => Integer, :default => 0
  field :version, :type => Integer, :default => 0
  field :version_date, :type => Hash, :default => {}
  field :uploader_ids, :type => Hash, :default => {}
  field :md5hash, :type => Hash, :default => {}
  field :md5s, :type => Array, :default => []
  field :created_ats, :type => Hash, :default => {}
  field :slides_counts, :type => Hash, :default => {}
  field :thanked_user_ids,:type=>Array,:default => []
  field :disliked_user_ids,:type=>Array,:default => []
  field :redirect_to_id
  has_many :comments, as: :commentable
  #-=xunlei=-
  embeds_many :notes
  field :xunlei_url
  field :ibeike_id
  field :ibeike_id2
  field :ibeike_uid
  field :ibeike_uname
  belongs_to :user
  cache_consultant :title
  before_validation :titleize
  
  
  
  ###liber add new upload page
  field :upload_persentage,:type=>Integer,:default => 100
  field :keywords,:type=>Array,:default=>[]                 
  field :enable_monetization,:type=>Boolean,:default=>false # 允许获利
  field :monetization_style,:type => Array,:default=>[]     # 获利方式
  field :enable_overlay_ads,:type=>Boolean,:default=>false  # 课件内嵌重叠式广告 
  field :trueview_instream,:type=>Boolean,:default=>false   # TrueView 插播广告  
  field :paid_product,:type=>Boolean,:default=>false        # 此课件中包含一个付费产品展示位置
  field :allow_syndication,:type=>Boolean,:default=>false   # 所有平台
  field :allow_comments,:type=>Boolean,:default=>true       # 允许评论
  field :allow_comments_detail,:type=>Integer,:default => 0
  
  ALLOW_DETAIL = {
    0 => 'all',
    1 => 'approval'
  }
  ALLOW_CN = {
    0 => "全部",
    1 => "已批准"
  }
  ALLOW_DETAL_EN = {
    'all' => "全部",
    'approval' => "已批准"
  }
  
  field :allow_comment_ratings,:type=>Boolean,:default=>true  #用户可对评论投票
  field :allow_ratings,:type=>Boolean,:default=>true          #用户可以查看此课件的评分
  field :allow_responses,:type=>Boolean,:default=>true        #是否允许用课件回复
  field :allow_responses_detail,:type=>Integer,:default => 1
  field :allow_embedding,:type=>Boolean,:default=>true  #允许嵌入
  field :creator_share_feeds,:type=>Boolean,:default=>true # 通知粉丝 

  def analyse2(two)
    if two
      the_rest = two.dup
      delim = ':'
      rests = the_rest.split(delim)
      if 1 == rests.size
        delim = '：'
        rests = the_rest.split(delim)
      end
      if 1 == rests.size
        self.user_name = self.uploader.name
        self.title_short = self.title.strip
      else
        self.user_name = rests[0].strip
        self.title_short = rests[1..-1].join(delim).strip
      end
    end
    
  end
  
  
  def disliked_by_user(user)
    self.disliked_user_ids ||=[]
    uploader = User.find(self.uploader_id) if self.uploader_id
    if user.thanked_courseware_ids.include?(self.id)
      user.thanked_courseware_ids.delete(self.id)
      self.thanked_user_ids.delete(user.id)
      ## counter
      uploader.thanked_count -= 1
      user.thank_count -= 1

      self.thanked_count -= 1
      ##
      user.save(:validate=>false)
    end
    if self.disliked_user_ids.index(user.id)
      self.disliked_user_ids.delete(user.id)
      ## counter
      uploader.disliked_count -= 1
      user.dislike_count -=1

      self.disliked_count -= 1
      ##
      self.save(:validate=>false)
      uploader.save(:validate => false)
      user.save(:validate=>false)
      return false
    end
    self.disliked_user_ids << user.id
    ## counter
    uploader.disliked_count += 1 if uploader
    user.dislike_count += 1

    self.disliked_count += 1
    ##
    self.save(:validate=>false)
    user.save(:validate => false)
    uploader.save(:validate => false) if uploader
    return true
  end
  def titleize
    if self.title.present? and (self.new_record? or self.title_changed?)
      self.title.strip!
      reg1 = /^\[([^\[\]]+)\](.*)$/
      reg2 = /^【([^【】]+)】(.*)$/
      reg3 = /^@([^:：]*)[:：](.*)$/
      if self.title =~ reg1
        self.school_name = $1.strip
        self.analyse2($2)
      elsif self.title =~ reg2
        self.school_name = $1.strip
        self.analyse2($2)
      elsif self.title =~ reg3
        u=User.where(:slug=>$1).first
        u||=User.where(:name=>$1).first
        if !u
          u = User.new
          u.name = $1
          u.valid?
          if u.errors[:name].present?
            u.name = "_#{$1}"
            unless u.errors[:name].present?
              u.name_unknown = true
            end
          end
          u.slug = nil
          u.auto_slug
          u.email_unknown = true
          u.save(:validate => false)
        end
        self.user_id = u.id
        self.school_name = nil
        self.title_short = $2
      else
        self.school_name = nil
        self.title_short = self.title
      end
      if self.topic.blank?
        self.topic = '课程请求'
      end
    end
  end
  def uploader
    @uploader = nil if self.uploader_id_changed?
    @uploader ||= User.where(id:self.uploader_id).first
  end
  def topic_inst
    ret = nil
    ret = Topic.where(:_id => self.topic_id).first unless self.topic_id.blank?
    if ret.nil?
      ret = Topic.locate('课程请求')
      self.update_attribute(:topic_id,ret.id)
    end
    ret
  end
  def topic_inst_was
    ret = nil
    ret = Topic.where(:_id => self.topic_id_was).first unless self.topic_id_was.blank?
    if ret.nil?
      ret = Topic.locate('课程请求')
    end
    ret
  end
  def school
    return nil if self.school_id.blank?
    School.where(:_id => self.school_id).first
  end
  def user
    return nil if self.user_id.blank?
    @user = nil if self.user_id_changed?
    @user ||= User.where(:_id => self.user_id).first
  end
  before_save :create_stuff!,:if=>'self.title_changed?'
  def create_stuff!
    self.is_thin = self.thin?
    if self.school_name.present?
      school = School.find_or_create_by(:name => self.school_name)
      user = User.find_or_initialize_by(:school_id => school.id, :name => self.user_name)
      if user.new_record?
        user.email_unknown = true
        user.save(:validate => false)
      end
      self.school_id = school.id
      self.user_id = user.id
    elsif self.user_id.blank?
      self.user_id = self.uploader_id
    end
  end
  before_save :create_topic!,:if=>'self.topic_changed?'
  def create_topic!
    topic = Topic.find_or_create_by(:name => self.topic)
    self.topic_id = topic.id
    self.topics = topic.ancestors
  end
  before_save :counter_work
  def update_pl
    pls = PlayList.where(:content=>self.id)
    pls.each do |pl|
      pl.save(:validate=>false)
    end
  end
  def counter_work
    @ktvidchangedandpresent = false
    @statuschangedandeq0 = false
    if user_id_changed?
      if user_id_was.present? and old_user = User.where(:_id=>user_id_was).first
        old_user.inc(:coursewares_count,-1)
        old_user.school.inc(:coursewares_count,-1) if old_user.school
      end
      self.user.inc(:coursewares_count,1)
      self.user.school.inc(:coursewares_count,1) if self.user.school
    end
    if status_changed? and (0==status || 0==status_was)
      if !uploader_id_changed? 
        self.uploader.inc(:coursewares_uploaded_count,1) if self.uploader
      end
      @statuschangedandeq0 = true
    end
    if ktvid_changed? and (ktvid.present? || ktvid_was.present?)
      @ktvidchangedandpresent = true
    end
    if uploader_id_changed? and 0==status
      if uploader_id_was.present? and old_user = User.where(:id=>uploader_id_was).first
        old_user.inc(:coursewares_uploaded_count,-1)
      end
      newuploader = self.uploader_ins
      newuploader.inc(:coursewares_uploaded_count,1) if newuploader
    end
    # if uploader_id_candidates_changed?
    #   added = uploader_id_candidates - uploader_id_candidates_was.to_a
    #   deleted = uploader_id_candidates_was.to_a - uploader_id_candidates
    #   added.each do |u|
    #     # User.find(u).inc(:coursewares_uploaded_count,1)
    #   end
    #   deleted.each do |u|
    #     # User.find(u).inc(:coursewares_uploaded_count,-1)
    #   end
    # end
    if slides_count_changed?
      pls = PlayList.where(:content=>id)
      pls.each do |pl|
        pl.content_total_pages = pl.content_total_pages - slides_count_was + slides_count
        pl.save(:validate=>false)
      end
    end
  end  
  before_save :course_work
  def course_work
    if course_fid_changed? 
      if !new_record? and !course_fid_was.nil?
        old_course = Course.where(:fid => course_fid_was).first
      end
      c = Course.where(:fid => self.course_fid).first
      if c
        c.inc(:coursewares_count,1)
        cd = c.department_ins.reload
        if (old_course and (od = old_course.department_ins.reload).id != cd.id) or !old_course
          cd.inc(:coursewares_count,1)
        end
        if old_course
          if od.id != cd.id
            od.inc(:coursewares_count,-1)
          end
          old_course.inc(:coursewares_count,-1)
        end
      end
      calculate_department_fid
    end
  end
  after_save :update_playlist
  def update_playlist
    if @statuschangedandeq0
      if ktvid.present?
        self.update_pl
      end
    end
    if @ktvidchangedandpresent
      if 0==status
        self.update_pl
      end
    end
  end

  before_save :teachers_work
  def teachers_work
    if status_changed? && status_was !=0 && status != 0
      # return
    end
    if status_changed? && status_was == 0 && status != 0
      if teachers_changed? && !teachers.blank?
        teachers_was.to_a.uniq.to_a.each do |a|
          next if a == "教师请求"
          t = Teacher.find_or_create_by(:name=>a)
          t.inc(:coursewares_count,-1)
        end
      else
        teachers.to_a.uniq.each do |a|
          next if a == "教师请求"
          t = Teacher.find_or_create_by(:name=>a)
          t.inc(:coursewares_count,-1)
        end
      end
    end
    if status_changed? && status_was != 0 && status == 0
      if teachers_changed? && !teachers.blank?
        teachers.to_a.uniq.each do |a|
          next if a == "教师请求"
          t = Teacher.find_or_create_by(:name=>a)
          t.inc(:coursewares_count,1)
        end
      else
        teachers.to_a.uniq.each do |a|
          next if a == "教师请求"
          t = Teacher.find_or_create_by(:name=>a)
          t.inc(:coursewares_count,1)
        end
      end
    end

    if !status_changed? and teachers_changed? and !teachers.blank?
      teachers.to_a.uniq.each do |a|
        next if a == "教师请求"
        t = Teacher.find_or_create_by(:name=>a)
      end
      added =  teachers - teachers_was.to_a
      if !added.blank? && status == 0
        added.to_a.uniq.each do |d|
          next if d == "教师请求"
          t = Teacher.find_or_create_by(:name=>d)
          t.inc(:coursewares_count,1)
        end
      end
      deleted = teachers_was.to_a - teachers
      if !deleted.blank? && status == 0
        deleted.to_a.uniq.each do |d|
          next if d == "教师请求"
          t = Teacher.find_or_create_by(:name=>d)
          t.inc(:coursewares_count,-1)
        end
      end
    end
  end
  
  before_save :redirect_work
  def redirect_work
    self.uploader_id_candidates||=[]
    self.uploader_id_candidates.delete(uploader_id)
    if redirect_to_id_was.present?
      (uploader_id_changed? and !uploader_id_was.blank?) ? uploaderx = uploader_id_was : uploaderx = uploader_id
      old_re = Courseware.find(redirect_to_id_was)
      # old_re.uploader_id_candidates -= self.uploader_id_candidates
      if Courseware.where(redirect_to_id:redirect_to_id_was,uploader_id:uploaderx).size < 2
         old_re.uploader_id_candidates.delete(uploaderx)
      end  
      old_re.save(:validate=>false)
    end
    if (redirect_to_id_changed? or uploader_id_changed?) and redirect_to_id.present?
      cw = Courseware.find(redirect_to_id)
      if cw.uploader_id != uploader_id
        if !cw.uploader_id_candidates.include?(uploader_id)
          cw.uploader_id_candidates << uploader_id
        end
        if cw.uploader_id_candidates.include?(cw.uploader_id)
          cw.uploader_id_candidates.delete(cw.uploader_id)
        end
      end
      if uploader_id_changed? and cw.uploader_id_candidates.include?(uploader_id_was)
        cw.uploader_id_candidates.delete(uploader_id_was)
      end
      cw.save(:validate=>false)
      redirect_to_id_op
    end
  end
  def wh_ratio
    ret = self.width*1.0/self.height
    ret = 1.3333333333333333 if ret.nan?
    ret
  end
  def thin?
    return true if self.width.present? and self.height.present? and self.width < self.height
    return false
  end
  def revision(revision_overwrite = nil)
    if revision_overwrite.nil?
      thing = self.version
    else
      thing = revision_overwrite
    end
    if thing > 0
      revision = thing
    else
      revision = ''
    end
    revision
  end
  def slide_width
    return 960 if self.thin?
    return 1024
  end
  def go_to_normal
    self.update_attribute(:status,0)
    self.tire.update_index
    # insert_courseware_action_log('GONE_NORMAL')
  end
  def pinpic
    "cw/#{self.ktvid ? self.ktvid : self.id}/#{self.pinpicname}"
  end
  # 缩略图是否正常上传？
  field :check_upyun_result,:type=>Boolean,:default=>false
  def check_upyun
    status = `curl -I "http://ktv-pic.b0.upaiyun.com/#{self.pinpic}"`.split("\n")[0].to_s.strip
    status2 = `curl -I "http://ktv-pic.b0.upaiyun.com/cw/#{self.ktvid}/#{self.revision}thumb_slide_0.jpg"`.split("\n")[0].to_s.strip
    self.update_attribute(:check_upyun_result, ('HTTP/1.1 200 OK'==status) && ('HTTP/1.1 200 OK'==status2))
  end 
  def redirect_to_id_op
    x=self
    history=[x.id.to_s]
    candidates_history = x.uploader_id_candidates
    while x.redirect_to_id.present?
      x=Courseware.find(x.redirect_to_id)
      history << x.id.to_s
      candidates_history = x.uploader_id_candidates +  candidates_history
    end
    x.ua(:uploader_id_candidates,candidates_history.uniq)
    if history.uniq.size < history.size
        self.redirect_to_id = nil
        self.ktvid=x.ktvid
        return
    end
    self.redirect_to_id=x.id
    self.ktvid=x.ktvid
  end
  def self.additional_conditions(coursewares,params)
    coursewares = coursewares.where(:sort1=>params[:sort1]) if params[:sort1].present? and params[:sort1]!='all'
    if 'all'==params[:sort] or params[:sort].blank?
      # do nothing
    else
      coursewares = coursewares.where(:sort.in=>params[:sort].split('|'))
    end
    if 'all'==params[:order] or params[:order].blank?
      coursewares = coursewares.desc('created_at')
    else
      coursewares = coursewares.desc('slides_count') if 'slides_count1'==params[:order]
      coursewares = coursewares.asc('slides_count') if 'slides_count0'==params[:order]
      coursewares = coursewares.desc('price') if 'price1'==params[:order]
      coursewares = coursewares.asc('price') if 'price0'==params[:order]
      coursewares = coursewares.desc('thanked_count') if 'thanked_count1'==params[:order]
      coursewares = coursewares.asc('thanked_count') if 'thanked_count0'==params[:order]
      if 'human_time1'==params[:order] || 'human_time0'==params[:order]
        coursewares2 = coursewares.where(:human_time.gt=>0)
        if coursewares2.count>0
          coursewares = coursewares2 
        end
      end
      coursewares = coursewares.desc('human_time') if 'human_time1'==params[:order]
      coursewares = coursewares.asc('human_time') if 'human_time0'==params[:order]
    end
    return coursewares
  end
  def body
    Page.where(courseware_id:self.id.to_s).collect(&:body).join("\n\n")
  end
  def construct_pages_one!(body,page_index)
    print "."
    page = Page.find_or_create_by_courseware_id_and_page_index(self.id.to_s,page_index)
    page.courseware_ktvid = self.ktvid.to_s
    page.body = body
    page.save(:validate=>false)
  end
  def construct_pages!(pages)
    if self.cw_pages.count==pages.count
      print "x"
      STDOUT.flush
      return true
    else
      print "o"
      STDOUT.flush
    end
    pages.each_with_index do |body,index|
      next if body.blank?
      self.construct_pages_one!(body,index)
    end
    STDOUT.flush
  end
  def yasuobao?
    ([:zip,:rar,:'7z'].include? self.sort.to_sym) && (self.tree.present?)
  end
  def normal?
    0==self.status
  end
  validates_inclusion_of :sort,:in=>SORTSTR.keys.map{|x| [x.upcase,x.downcase]}.flatten
  def export_to_mainsite!
    presentation = {}
    slug = self.thread_inst.author
    presentation[:title]=self.title
    presentation[:pdf_filename]=self.title #chifanqu
    Sidekiq::Client.enqueue(HookerJob,Courseware,nil,presentations_upload_finished,presentation,slug)
  end
  def papa
    @papa = nil if self.father_id_changed?
    @papa ||= Courseware.find(self.father_id)
  end
  def self.push_trigger(id)
    # field :tree,:type=>Hash,:default=>{}
    # field :father_id
    # field :is_children,:type => Boolean, :default => false
    # field :where_am_i_in_this_family
    cw = Courseware.find(id)
    if cw.is_children
      papa = Courseware.find(cw.father_id)
      tmp = papa.get_children
      tstatus = tmp.map{|x| Courseware.find(x)}.compact.map(&:status).to_a
      if (tstatus.count(0)+tstatus.count(-1)+tstatus.count(-2)+tstatus.count(-3)) == tmp.to_a.size
        papa.update_attribute(:status,0)
      else
        papa.update_attribute(:status,4)
      end
      if tmp.blank?
        papa.ua(:sub_status,1)
      else
        papa.ua(:sub_status,0)
      end
      # @papa.update_attribute(:transcoding_count,@papa.transcoding_count - 1)
      # if @papa.transcoding_count <= 0
      # end
    end
  end
  def self.orphan
    cws = Courseware.where(:is_children => true)
    cws.each do |f|
      papa = Courseware.find(f.father_id)
      if !papa.get_children.to_s.include?(f.id.to_s)
        f.delete
      end
    end
  end
  def get_children      # return Array
    children = self.tree.to_s.scan(/"id"=>"([a-z0-9]{20,})"/).flatten.compact
  end
  def get_ctext
    children = self.tree.to_s.scan(/"id"=>"[a-z0-9]{20,}",."text"=>"([^"]*)"/).flatten.compact
  end
  def fix_children(fix_all = false)
    counting = 0
    self.get_children.each do |c|
      w = Courseware.find(c)
      if fix_all
        w.re_enqueue_prepare!
      end
      if w.status != 0
        if !fix_all
          w.re_enqueue_prepare!
        end
        w.enqueue!
        counting += 1
      end
    end
    if self.get_children.blank? and self.tree.present?
      self.go_to_normal
    end
    puts "father " + self.id.to_s.colorize(:red) + " has " + counting.to_s.colorize(:red) + " need to be fixed."
  end
  def self.fix_remote_filepath!(array)
     array.each do |f|
       c = Courseware.find(f)
       c.fix_remote_filepath
     end
  end
  def fix_remote_filepath
    if self.remote_filepath.include?("http") and self.remote_filepath.include?("media/b")
      tmp = "http://special_agentx.#{Setting.ktv_domain}/#{self.remote_filepath.split('media/b/auxiliary_'+Setting.ktv_sub + '/ftp/cw')[-1]}"
      self.ua(:remote_filepath,tmp)
    end
  end

  def self.fix_queue!(array)
    array.each do |f| 
      c = Courseware.find(f)
      if c.status == 1
        c.enqueue!
      else
        if c.tree.present?
          c.fix_children
        else
          c.enqueue!
        end
      end
    end
  end
  def self.check_match(array)
    array.each do |f|
      cw = Courseware.find(f)
      puts "father:[" + cw.id.to_s + "]"+cw.title.colorize(:blue)
      puts cw.get_ctext.to_s.colorize( :red )
    end
  end
  def check_children(key,statusArray=[])
    self.get_children.each do |c|
      w = Courseware.where(id:c).first
      if w.nil?
        puts "error!!!".colorize( :red )
        next
      end
      if statusArray.blank?
        puts w.id.to_s + ": ".to_s + w.send(key).to_s.colorize( :red )
      elsif statusArray == :abnormal
       if w.status != 0
          puts w.id.to_s + ": ".to_s + w.send(key).to_s.colorize( :red )
       end
      else
        if statusArray.include?(w.status)
          puts w.id.to_s + ": ".to_s  + w.send(key).to_s.colorize( :red )
        end
      end      
    end
  end
  def soft_delete_children
    self.get_children.each do |c|
      w = Courseware.find(c)
      w.soft_delete
      puts w.id.to_s+"has been soft deleted".colorize( :red )
    end
  end
  def hard_delete_children
    self.get_children.each do |c|
      w = Courseware.find(c)
      if w.deleted == 1
        w.delete
      else
        puts w.id.to_s.colorize( :red )
      end 
    end
  end
  def self.presentations_upload_finished(presentation,user)
    presentation = presentation.with_indifferent_access
=begin
presentation[category_id]	
presentation[description]	
presentation[id]	50002148100c37000104076b
presentation[name]	
presentation[pdf_filename]	Predefined Global Variables (Read Ruby 1.9).pdf
presentation[publish]	0
presentation[publish]	1
presentation[published_at]	2012/07/13
=end
    cw = nil
    cw ||= Courseware.where(:_id => presentation[:id]).first if presentation[:id].present?
    cw ||= Courseware.new
    if !user.respond_to?(:slug)
      user = User.find_by_slug(user)
    end
    cw.uploader_id = user.id
    cw.pdf_filename = presentation[:pdf_filename]
    cw.sort = File.extname(cw.pdf_filename).split('.')[-1]
    cw.sort1 = presentation[:sort1] if !presentation[:sort1].blank?
    cw.sort1 ||= ''
    cw.topic = presentation[:topic]
    if cw.topic.blank?
      cw.topic = '课程请求' 
    end
    teacher_tmp =  presentation[:teacher] == 'opt_psvr_add_more' ? presentation[:other_teacher] : presentation[:teacher]
    if teacher_tmp.blank?
      if !cw.teachers.include?('教师请求')
        cw.teachers << '教师请求'
      end
    else
      # cw.teachers.delete('教师请求')
      cw.teachers = [] # => need rewrite
      if !cw.teachers.include?(teacher_tmp)
        cw.teachers.unshift(teacher_tmp)
      end
    end
    
    cw.title = presentation[:title]
    cw.title = File.basename(cw.pdf_filename) if cw.title.blank?
    cw.title = '课件标题请求' if cw.title.blank?
    cw.extra_property_fill(presentation)
    cw.uploader_ids[cw.version.to_s]=cw.uploader_id
    cw.created_ats[cw.version.to_s]=cw.created_at
    
    if presentation[:is_children]
      cw.is_children = true
      cw.father_id = presentation[:father_id]
      cw.where_am_i_in_this_family = presentation[:where_am_i_in_this_family]
      cw.child_rank = presentation[:child_rank]
    else
      cw.is_children = false
      cw.where_am_i_in_this_family = presentation[:where_am_i_in_this_family]
    end
    
    if presentation[:auto_save] == "manual"
      cw.save(:validate=>false)
      return cw
    end
    cw.status = 1
    
    if presentation[:remote_filepath].blank?
      cw.really_remote = true
      cw.really_localhost = false
      cw.remote_filepath = "http://ktv-up.b0.upaiyun.com/#{user.id}/#{presentation[:uptime]}.pdf"
    else
      cw.remote_filepath = presentation[:remote_filepath]
      cw.really_remote = presentation[:really_remote]
      cw.really_localhost = presentation[:really_localhost]
      cw.really_localpath = presentation[:really_localpath]
      if presentation[:really_localhost] and presentation[:really_localpath].present?
        md5 = cw.md5 = Digest::MD5.hexdigest(File.read(presentation[:really_localpath]))
        cw.fileinfo_raw = Ktv::Utils.safely(''){`file "#{presentation[:really_localpath]}"`.force_encoding_zhaopin.strip.split(': ')[1..-1].join(': ')}
        cw.dz_file_manipulate
        cw.md5hash['0'] = md5
        cw.md5s = [md5]
        if md5_cw = Courseware.where('md5s'=>md5).first
          cw.redirect_to_id=md5_cw.id
          cw.redirect_to_id_op
          cw.status=0#-2
       end 
      end
    end
    cw.save(:validate=>false)
    if cw.is_children
      Sidekiq::Client.enqueue(HookerJob,"Courseware",nil,:push_trigger,cw.id) 
    end
    if -2==cw.status
      cw.go_to_normal
    else
      cw.enqueue!
    end

    cw
  end
  def re_enqueue_prepare!
    self.ua(:status,1)
    self.ua(:really_broken,false)
    self.ua(:check_upyun_result,false)
    self.ua(:pdf_slide_processed,0)
  end
  def enqueue!
    #raise 'Must first obtain a ktvid!' if self.ktvid.blank?
    self.make_sure_globalktvid!
    case self.sort.downcase.to_sym
    when :pdf,:djvu
      Sidekiq::Client.enqueue(TranscoderJob,self.id.to_s)
    when :ppt,:pptx
      Sidekiq::Client.enqueue(WinTransJobPPT,self.remote_filepath,self.sort,self.ktvid,self.id.to_s)
    when :doc,:docx
      Sidekiq::Client.enqueue(WinTransJobDOC,self.remote_filepath,self.sort,self.ktvid,self.id.to_s)
    when :zip,:rar,:'7z'
      Sidekiq::Client.enqueue(UncompressJob,self.id.to_s)
      # Sidekiq::Client.enqueue(HookerJob,"Ktv::Uncompress",nil,:perform,self.id)
    end
  end
  def renqueue!
    self.re_enqueue_prepare!
    self.enqueue!
  end
  def extra_property_fill(presentation)
    self.have_pw = '1'==presentation[:have_pw]
    self.pw = Digest::MD5.hexdigest(presentation[:pw]) unless presentation[:pw].blank?
    self.version_date[self.version.to_s] = presentation[:version_date]
  end
  def self.import_one(thread)
    ins=Courseware.find_or_initialize_by(tid:thread.tid)
    attachment = PreForumAttachment.where(tid:thread.tid).first
    if attachment
      a = "PreForumAttachment#{thread.tid.to_s[-1]}".constantize.find_by_aid(attachment.aid)
      ins.title = thread.subject
      ins.filesize = a.filesize / 1000
      ins.dz_filepath = "#{Rails.root}/simple/simple/data_#{Setting.ktv_sub}/attachment/forum/#{a.attachment}"
      ins.fileinfo_raw = Ktv::Utils.safely(''){`file "#{ins.dz_filepath}"`.force_encoding_zhaopin.strip.split(': ')[1..-1].join(': ')}
      ins.dz_file_manipulate
      begin
        file_content = File.read(ins.dz_filepath)
        ins.md5 = Digest::MD5.hexdigest(file_content)
      rescue Errno::ENOENT => e
        return false
      end
      ins.pdf_filename = a.filename
      ins.sort = File.extname(a.filename).to_s.downcase
      ins.sort = ins.sort[1..-1] if '.'==ins.sort[0]
      ins.downloads_count = attachment.downloads
      ins.course_fid=thread.fid
      ins.teacher_typeid=thread.typeid
      inst = PreForumThreadclass.find_by_typeid(thread.typeid)
      ins.teacher=inst.name if inst
      ins.author = thread.author
      ins.uid = thread.authorid
      ins.uploader_id = User.find_by_slug(ins.author).id
      ins.save(:validate=>false)
    end
  end
  def fileinfo_raw_import
    self.fileinfo_raw = Ktv::Utils.safely(''){`file "#{self.remote_filepath}"`.force_encoding_zhaopin.strip.split(': ')[1..-1].join(': ')}
  end
  def dz_file_manipulate
    self.fileinfo=self.fileinfo_raw
    
    if pos=(self.fileinfo =~ /, \w+:/)
      self.fileinfo[pos]='.'
      self.fileinfo.insert(pos, ", 共#{self.slides_count}页")
    end
    
    if self.fileinfo =~ /Number of Words: (\d+)/
      orig = "Number of Words: #{$1}"
      self.words_count=$1.to_i
      repl = "字数: #{self.words_count}"
      self.fileinfo.gsub!(orig,repl)
    end
    
    
    
    if self.fileinfo =~ /Last Printed: ([^,]+),/
      orig = "Last Printed: #{$1}"
      repl = "文件上次打印于: #{Time.parse($1).strftime('%Y年%m月%d日 %H:%M:%S')}"
      self.fileinfo.gsub!(orig,repl)
    end
    if self.fileinfo =~ /Create Time\/Date: ([^,]+),/
      orig = "Create Time/Date: #{$1}"
      self.started_at=Time.parse($1)
      repl = "创作开始于: #{self.started_at.strftime('%Y年%m月%d日 %H:%M:%S')}"
      self.fileinfo.gsub!(orig,repl)
    end
    if self.fileinfo =~ /Last Saved Time\/Date: ([^,]+),/
      orig = "Last Saved Time/Date: #{$1}"
      self.finished_at=Time.parse($1)
      repl = "创作结束于: #{self.finished_at.strftime('%Y年%m月%d日 %H:%M:%S')}"
      self.fileinfo.gsub!(orig,repl)
    end
    if self.fileinfo =~ /Total Editing Time: ([^,]+),/
      orig = "Total Editing Time: #{$1}"
      duration = $1.split('+').join(' ')
      self.human_time = ChronicDuration.parse(duration)
      repl = "作者创作时间投入: #{self.human_time_human}"
      self.fileinfo.gsub!(orig,repl)
    end
    {
      'CDF V2 Document' => '复合文档格式2.0版本',
      'Composite Document File V2 Document' => '复合文档格式2.0版本',
      'PDF document, version 1.6' => 'PDF文档, 1.4版本',
      'PDF document, version 1.5' => 'PDF文档, 1.4版本',
      'PDF document, version 1.4' => 'PDF文档, 1.4版本',
      'PDF document, version 1.3' => 'PDF文档, 1.3版本',
      'PDF document, version 1.2' => 'PDF文档, 1.2版本',
      'PDF document, version 1.1' => 'PDF文档, 1.1版本',
      'Zip archive data, at least v2.0 to extract' => 'Zip压缩包, 2.0+版本',
      'Zip archive data' => 'Zip压缩包',
      '7-zip archive data, version 0.3' => '7-zip压缩包, 0.3版本',
      '7-zip archive data, version 0.2' => '7-zip压缩包, 0.2版本',
      '7-zip archive data, version 0.1' => '7-zip压缩包, 0.1版本',
    }.each do |k,v|
      if self.fileinfo.scan(k).present?
        self.filesort_mundane = self.filesort = v.gsub(', ','')
        self.fileinfo.gsub!(k,v)
      end
    end
    if self.fileinfo =~ /Name of Creating Application: ([^,]+),/
      orig = "Name of Creating Application: #{$1}"
      self.filesort_mundane = "#{$1.split(' ')[-1]}文档"
      repl = "创作所用软件: #{$1}"
      self.fileinfo.gsub!(orig,repl)
    end
    for k,v in FILE_INFO_TRANS
      self.fileinfo.gsub!(k,v)
    end
    self.fileinfo.strip!
    self.filesort_mundane = self.fileinfo if self.filesort_mundane.blank?
    self.fileinfo+='.' unless self.fileinfo.ends_with?('.')
  end
  def self.import_all!
    PreForumThread.all.each do |thread|
      import_one(thread)
    end
  end
  def self.kj_to_sub
    File.open("/tmp/3.rb","w"){|f| @r.each{|x| if cw=Courseware.where(:remote_filepath=>x).first;f.puts "Courseware.where(:really_localpath=>#{x.inspect}).first.update_attributes(:status=>#{cw.status},:width=>#{cw.width.inspect},:height=>#{cw.height.inspect},:real_width=>#{cw.real_width.inspect},:real_height=>#{cw.real_height.inspect},:slides_count=>#{cw.slides_count.inspect},:pdf_slide_processed=>#{cw.pdf_slide_processed.inspect},:ktvid=>#{cw.id.to_s.inspect})";end;}}
  end
  def inject_transcoder
opts={   :subsite=>Setting.ktv_sub,
  :tid=>self.tid,
      :author=>self.author,
      :sort=>self.sort,
      :pdf_filename=>self.pdf_filename,
      :dz_filepath=>self.dz_filepath,
      :title=>self.title
}
    Sidekiq::Client.enqueue(InjectTranscoderJob,:dz,opts)
  end
  def cover_small
    self.topic_inst.cover.small.url
  end
  def cover_small_was
    self.topic_inst_was.cover.small.url
  end
  def cover_small_changed?
    self.topic_id_changed?
  end
  def make_sure_globalktvid!
    if self.ktvid.blank?
      ret = UCenter::App.get_new_ktvid(nil,{subsite:Setting.ktv_sub})
      self.update_attribute(:ktvid,ret) if Moped::BSON::ObjectId.legal?(ret)
    end
  end
  after_destroy lambda { tire.update_index }
  def self.selfdestruction(id)
    begin
      cw = Courseware.find(id)
      tmp = cw.tree.to_s.scan(/"id"=>"([a-z0-9]{20,})"/).flatten
      tmp.each {|x| Courseware.find(x).destroy;puts "child:#{x} has been killed"}
      cw.destroy;
      puts "father has been killed"
      return true
    rescue =>e
      raise e
    end
  end
  def self.self_today_hard_clean
    uploader_id = Array.new
    garbage = Courseware.where(:created_at.gt => 1.day.ago)
    puts "************************************************\nGarbage:total #{garbage.size} .They will be deleted.\n************************************************"
    garbage.each do |x|
      if x.tree.present?
        Courseware.selfdestruction(x.id)
      end
      PlayList.where(:content=>x.id).each do |y|
        y.content.delete(x.id)
        y.save(:validate=>false)
      end
    end
    Courseware.where(:created_at.gt => 1.day.ago).map{|x| x.delete}
    return true
  end
  def redis_search_alias
    [self.keywords.to_a.join(', '),self.teachers.to_a.join(', '),self.course_name].map { |e| e if e.present? }.compact.join(', ')
  end
  def redis_search_alias_changed?
    self.keywords_changed? or self.teachers_changed? or self.course_fid_changed?
  end
  def redis_search_alias_was
    [self.keywords_was.to_a.join(', '),self.teachers_was.to_a.join(', '),self.course_name_was].map { |e| e if e.present? }.compact.join(', ')
  end
  def course_name
    Course.get_name(self.course_fid)
  end
  def course_name_changed?
    self.course_fid_changed?
  end
  def course_name_was
    Course.get_name(self.course_fid_was)
  end
  redis_search_index(:title_field => :title,
                     :alias_field => :redis_search_alias,
                     :score_field => :score,
                     :ext_fields => [:teachers,:course_name,:slides_count],
                     :prefix_index_enable => false,
                    )
  alias_method :redis_search_index_create_before_psvr,:redis_search_index_create
  alias_method :redis_search_index_need_reindex_before_psvr,:redis_search_index_need_reindex
  def redis_search_psvr_okay?
    !self.soft_deleted? and 0==self.status and 0==self.privacy and self.title.present? and self.redis_search_alias.present?
  end
  attr_accessor :force_redis_search_psvr_changed
  def redis_search_psvr_changed?
    return true if force_redis_search_psvr_changed
    (self.deleted_changed? || self.status_changed? || self.privacy_changed?)
  end
  def redis_search_index_need_reindex
    if !redis_search_psvr_okay?
      redis_search_index_destroy
      redis_search_psvr_was_delete!
      return false
    else
      return (self.redis_search_psvr_changed? || self.redis_search_index_need_reindex_before_psvr)      
    end
  end

  def redis_search_index_create
    self.redis_search_index_create_before_psvr if self.redis_search_psvr_okay?
  end
  def self.psvr_redis_search(q,liber_terms,lim)
    ret = Redis::Search.query("Courseware",q,:limit=>lim,:sort_field=>'score')
    ret += Redis::Search.query("Courseware",liber_terms,:limit=>lim,:sort_field=>'score') if ret.size<lim
    ret = ret.psvr_uniq.limit(lim)
    ret
  end
  include Tire::Model::Search
  PSVR_ELASTIC_MAPPING = {
    "title"=>{"type"=>"string",'boost'=>10,'analyzer'=>'psvr_analyzer'},
  }
  def psvr_tire_changed?
    ret = false
    PSVR_ELASTIC_MAPPING.keys.each do |key|
      ret ||= self.send("#{key}_changed?")
    end
    ret
  end
  index_name proc{self.elastic_search_psvr_index_name}
  before_save lambda {
    @psvr_was_a_new_record = new_record?
    true
  }
  after_save lambda {
    instance = self
    if redis_search_psvr_okay?
      if redis_search_psvr_changed? || psvr_tire_changed?
        tire.update_index
      end
    else
      Tire.index(self.class.elastic_search_psvr_index_name) do
        remove instance
      end
    end
    if redis_search_psvr_changed?
      # 这是一种隐藏性变更，在这种情况下，要处理Page
      if redis_search_psvr_okay?
        Sidekiq::Client.enqueue(RedundancyHookerJob,
          'Page',
          nil,
          'do_index_them_for_cw',
          self.id.to_s
        )
      else
        unless @psvr_was_a_new_record
          Sidekiq::Client.enqueue(RedundancyHookerJob,
            'Page',
            nil,
            'do_unindex_them_for_cw',
            self.id.to_s
          )
        end
      end
    end
    true
  }
  def self.reconstruct_indexes!
    Tire.index(elastic_search_psvr_index_name) do
      delete
      create(:settings=>{
        'analysis'=>{
          'analyzer'=>{
            'psvr_analyzer'=>{
              type: 'custom',
              tokenizer: 'smartcn_sentence',
              filter: [ 'smartcn_word' ],
            },
          }
        }
      },
      :mappings=>{
        "courseware"=>{"properties"=>PSVR_ELASTIC_MAPPING.merge({
          'body'=>{"type"=>"string",'analyzer'=>'psvr_analyzer'},
          "id"=>{"type"=>"string",'index'=>'not_analyzed'},
        })}
      })
      refresh
    end
  end
  include_root_in_json = false
  def to_indexed_json
    h={}
    h[:id] = self.id
    h[:body] = self.body
    PSVR_ELASTIC_MAPPING.keys.each do |field|
      h[field] = self.send(field)
    end
    h.to_json
  end
  def self.psvr_search(from,size,params,apart_from=[])
    h={
      "query"=> {
        "bool"=> {
          "must"=> [],
          "must_not"=> apart_from.blank? ? [] : [
            {
              "ids"=>{
                "values"=> apart_from
              }
            }
          ],
          "should"=> [
            {
              "query_string"=> {
                "default_field"=> "title",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
                "boost"=>10,
              }
            },
            {
              "query_string"=> {
                "default_field"=> "body",
                "query"=> params[:q],
                "analyzer" => "psvr_analyzer",
                "default_operator"=> "AND",
              }
            }
          ]
        }
      },
      "from"=> from,
      "size"=> size,
      "sort"=> ["_score"],
      "highlight" => {
        "pre_tags" => [""],
        "post_tags" => [""],
        "fields" => {
          "title" => {"number_of_fragments" => 0},
          "body" => {"fragment_size" => 50, "number_of_fragments" => 3}
        }
      },
      "facets"=> {}
    }
    url = "http://localhost:9200/#{elastic_search_psvr_index_name}/courseware/_search?from=#{from}&size=#{size}&fields=id"
    response = Tire::Configuration.client.get(url, h.to_json)
    if response.failure?
      STDERR.puts "[REQUEST FAILED] #{h.to_json}\n"
      raise Ktv::Shared::SearchRequestFailed, response.to_s
    end
    json     = MultiJson.decode(response.body)
    return Tire::Results::Collection.new(json, :from=>from,:size=>size)
  end
  SORT1TYPEID = {
    'lecture_notes' => 1,
    'assignments' => 2,
    'exams' => 3,
    'videos' => 4,
    'materials' => 5,
  }
  after_save :sync_to_dz!
  def sync_to_dz_okay?
    self.is_father? and self.title.present? and self.uploader.discuz_user_activated
  end
  def sync_to_dz_changed?
    self.title_changed? or self.uploader_id_changed?
  end
  def sync_to_dz!
    return true unless self.sync_to_dz_okay?
    # todo: consider sync_to_dz_changed?
    return true if self.try(:tid).try(:>,0)
    data = {
      psvr_posttime_overwrite:self.created_at.to_i,
      wysiwyg:1,
      typeid:SORT1TYPEID[self.sort1],
      subject:self.title,
      message:'[code]'+MultiJson.dump(self.as_json_before_psvr)+'[/code]',
      replycredit_extcredits:0,
      replycredit_times:1,
      replycredit_membertimes:1,
      replycredit_random:100,
      readperm:'',
      price:99,
      tags:'',
      rushreplyfrom:'',
      rushreplyto:'',
      rewardfloor:'',
      stopfloor:'',
      creditlimit:'',
      save:'',
      usesig:1,
      allownoticeauthor:1
    }
    res = Ktv::JQuery.ajax({
      psvr_original_response: true,
      url:"http://#{Setting.ktv_subdomain}/simple/forum.php?mod=post&action=newthread&fid=#{self.course_fid}&extra=&topicsubmit=yes",
      type:'POST',
      data:data,
      :accept=>'raw'+Setting.dz_authkey,
      psvr_response_anyway: true,
      :psvr_extra_headers=>{
        'PSVR-XXX-UID-OVERWRITE'=>self.uploader.uid.to_s
      },
    })
    if res.psvr_extra_arg =~ /&tid=(\d+)&/
      self.update_attribute(:tid,$1.to_i)
      self.update_attribute(:tid,PreForumPost.where(tid:self.tid,first:1).first.pid)
      User.get_credits(self.uploader.uid,true)
      puts "sync_to_dz! success #{self.tid}"
    end
    true 
  end
end
