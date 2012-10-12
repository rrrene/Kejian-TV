# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter proc{
    puts request.env['HTTP_USER_AGENT']+request.ip
    puts ' '
    puts request.path
    # text = request.user_agent    
    # render text:text and return
  }
  unless $psvr_really_development
    rescue_from Exception, with: :render_500
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
  end
  def render_401(exception=nil)
    redirect_to root_path,:alert => '对不起，权限不足！'
    return false
  end
  def render_404(exception=nil)
    @not_found_path = exception ? exception.message : ''
    respond_to do |format|
      format.html { render file: "#{Rails.root}/simple/404.html", layout: false, status: 404 }
      format.all { render nothing: true, status: 404 }
    end
    return false
  end
  def render_500(exception=nil)
    @not_found_path = exception ? exception.message : ''
    if e = exception
      str = "#{Time.now.getlocal}\n"
      str += "#{request.request_method} #{request.path} #{request.ip}\n"
      str += "#{request.user_agent}\n"
      str += e.message+"\n"+e.backtrace.join("\n")
      str += "\n---------------------------------------------\n"
      $debug_logger.fatal(str)
    end
    respond_to do |format|
      format.html { render file: "#{Rails.root}/simple/500.html", layout: false, status: 500 }
      format.all { render nothing: true, status: 500 }
    end
    return false
  end
  layout :layout_by_resource
  def layout_by_resource
    if devise_controller?
      "application_for_devise"
    elsif request.path.starts_with?('/embed/')
      "embedded"
    else
      "application"
    end
  end
  
  before_filter :request_referer
  def request_referer
      if !request.referer.nil? and !URI(request.referer).host.include?('kejian')
          if current_user.nil?
              cuid = nil
          else
              cuid = current_user.id
          end
          CwEvent.add_come_event('Courseware','',request.ip,cuid,request.referer)
          session[:referer] = request.referer
      end
  end
  
  before_filter :set_vars
  before_filter :xookie,:unless=>'devise_controller?'
  before_filter :dz_security
  
  def set_vars
    @seo = Hash.new('')
    agent = request.env['HTTP_USER_AGENT'].downcase
    @is_bot = (agent.match(/\(.*https?:\/\/.*\)/)!=nil)
    @is_mac = (agent.index('macintosh')!=nil)
    @is_windows = (agent.index('windows')!=nil)
    @is_firefox = (agent.index('firefox')!=nil)
    @is_chrome = (agent.index('chrome')!=nil)
    @is_ie = (agent.index('msie')!=nil)
    @is_WebKit = (agent.index('webkit')!=nil)
    @is_ie6 = (agent.index('msie 6')!=nil)
    @is_ie7 = (agent.index('msie 7')!=nil)
    @is_ie8 = (agent.index('msie 8')!=nil)
    @is_ie9 = (agent.index('msie 9')!=nil)
    @is_ie10 = (agent.index('msie 10')!=nil)
    @bg_index = rand(Setting.fotos.count)
  end
  def xookie
    if !$psvr_really_development
      res = Discuz::Request.touch(request)
      res.cookies.each do |key,value|
        if(key.ends_with?('_lastact'))
          cookies[key]="#{value.split('%09')[0]}%09#{CGI::escape(request.path)}%09"
        else
          cookies[key]=value
        end
      end
      @_G = JSON.parse(res.to_s)
    else
      @_G= {"uid"=>"35", "username"=>"libo-liu", "adminid"=>"1", 
"groupid"=>"1", "sid"=>"co6B65", "formhash"=>"c075d4b7", "connectguest"=>0, 
"timestamp"=>1349512472, "starttime"=>1349512472.7136, "clientip"=>"127.0.0.1", 
"referer"=>"", "charset"=>"utf-8", "gzipcompress"=>false, "authkey"=>"98107cdd0c8268b6ee3013770e8a09a0", 
"timenow"=>{"time"=>"2012-10-6 16:34", "offset"=>"+8"}, "widthauto"=>0, "disabledwidthauto"=>0, 
"PHP_SELF"=>"/simple/touch.php", "siteurl"=>"http://cnu.kejian.lvh.me/simple/", "siteroot"=>"/simple/", 
"siteport"=>"", "config"=>{"db"=>{"1"=>{"dbhost"=>"localhost", "dbuser"=>"root", "dbpw"=>"jknlff8-pro-17m7755", 
"dbcharset"=>"utf8", "pconnect"=>"0", "dbname"=>"ktv_sub_cnu", "tablepre"=>"pre_"}, "common"=>{"slave_except_table"=>""}}, 
"memory"=>{"prefix"=>"04X3QL_", "redis"=>{"server"=>"", "port"=>6379, "pconnect"=>1, "timeout"=>"0", "serializer"=>1}, 
"memcache"=>{"server"=>"", "port"=>11211, "pconnect"=>1, "timeout"=>1}, "apc"=>1, "xcache"=>1, "eaccelerator"=>1}, 
"server"=>{"id"=>1}, "download"=>{"readmod"=>2, "xsendfile"=>{"type"=>"0", "dir"=>"/down/"}}, "cache"=>{"type"=>"sql"}, 
"output"=>{"charset"=>"utf-8", "forceheader"=>1, "gzip"=>"0", "tplrefresh"=>1, "language"=>"zh_cn", "staticurl"=>"static/", 
"ajaxvalidate"=>"0", "iecompatible"=>"0"}, "cookie"=>{"cookiepre"=>"6tce_af6d_", "cookiedomain"=>"cnu.kejian.lvh.me", "cookiepath"=>"/"}, 
"security"=>{"authkey"=>"0b7310esiKtBIrpX", "urlxssdefend"=>1, "attackevasive"=>"0", "querysafe"=>{"status"=>1, 
"dfunction"=>["load_file", "hex", "substring", "if", "ord", "char"], "daction"=>["intooutfile", "intodumpfile", "unionselect",
"(select", "unionall", "uniondistinct"], "dnote"=>["/*", "*/", "#", "--", "\""], "dlikehex"=>1, "afullnote"=>"0"}}, 
"admincp"=>{"founder"=>"1", "forcesecques"=>"0", "checkip"=>1, "runquery"=>"0", "dbimport"=>1}, 
"remote"=>{"on"=>"0", "dir"=>"remote", "appkey"=>"62cf0b3c3e6a4c9468e7216839721d8e", "cron"=>"0"}, "input"=>{"compatible"=>1}}, 
"setting"=>{"accessemail"=>"", "activityforumid"=>"0", "activityfield"=>"a:3:{s:8:\"realname\";s:12:\"真实姓名\";s:6:\"mobile\";s:6:\"手机\";s:2:\"qq\";s:5:\"QQ号\";}",
"activityextnum"=>"0", "activitypp"=>"8", "activitycredit"=>"1", "activitytype"=>"朋友聚会\r\n出外郊游\r\n自驾出行\r\n公益活动\r\n线上活动", "adminemail"=>"pmq2001@gmail.com", 
"adminipaccess"=>"", "adminnotifytypes"=>"verifythread,verifypost,verifyuser,verifyblog,verifydoing,verifypic,verifyshare,verifycommontes,verifyrecycle,verifyrecyclepost,verifyarticle,verifyacommont,verifymedal,verify_1,verify_2,verify_3,verify_4,verify_5,verify_6,verify_7",
"anonymoustext"=>"匿名", "advtype"=>[], "allowattachurl"=>"0", "allowdomain"=>"0", "alloweditpost"=>"0", 
"allowswitcheditor"=>"1", "allowviewuserthread"=>"", "archiver"=>"1", "archiverredirect"=>"0", "attachbanperiods"=>"", 
"attachdir"=>"/Users/Liber/ktv/sub/simple/simple/./data_cnu/attachment/", "attachexpire"=>"1", "attachimgpost"=>"1", "attachrefcheck"=>"1", 
"attachsave"=>"3", "attachurl"=>"data_cnu/attachment/", "authkey"=>"0b7310esiKtBIrpX", "authoronleft"=>"1", "autoidselect"=>"0", "avatarmethod"=>"0", 
"bannedmessages"=>"1", "bbclosed"=>"0", "bbname"=>"首都师范大学课件交流系统", "bbrules"=>"0", "bbrulesforce"=>"0", "bbrulestxt"=>"", "bdaystatus"=>"0", 
"binddomains"=>"a:0:{}", "boardlicensed"=>"0", "cacheindexlife"=>"0", "cachethreaddir"=>"data_cnu/threadcache", "cachethreadlife"=>"0", "censoremail"=>"", 
"censoruser"=>"", "closedallowactivation"=>"0", "commentfirstpost"=>"1", "commentitem"=>["", "", "", "", "", ""],
"commentnumber"=>0, "creditnotice"=>"1", "creditsformula"=>"$member['posts']+$member['digestposts']*5+$member['extcredits1']*2+$member['extcredits2']+$member['extcredits3']", 
"creditsformulaexp"=>"<u>总积分</u>=<u>发帖数</u>+<u>精华帖数</u>*5+<u>威望</u>*2+<u>金钱</u>+<u>贡献</u>", 
"creditspolicy"=>{"post"=>[], "reply"=>[], "digest"=>{"1"=>10}, "postattach"=>[], "getattach"=>[], "sendpm"=>[], "search"=>[], 
"promotion_visit"=>true, "promotion_register"=>true, "tradefinished"=>[], "votepoll"=>[], "lowerlimit"=>[]},
"creditstax"=>"0.2", "creditstrans"=>"2", "dateconvert"=>"1", "dateformat"=>"Y-n-j", "debateforumid"=>"0", "debug"=>"1", 
"defaulteditormode"=>"1", "delayviewcount"=>"0", "deletereason"=>"", "disallowfloat"=>"newthread", "domainroot"=>"", "doublee"=>"1", 
"dupkarmarate"=>"0", "ec_account"=>"", "ec_contract"=>"", "ec_credit"=>{"maxcreditspermonth"=>6, 
"rank"=>{"1"=>4, "2"=>11, "3"=>41, "4"=>91, "5"=>151, "6"=>251, "7"=>501, "8"=>1001, "9"=>2001, "10"=>5001, "11"=>10001, "12"=>20001, 
"13"=>50001, "14"=>100001, "15"=>200001}}, "ec_maxcredits"=>"1000", "ec_maxcreditspermonth"=>"0", "ec_mincredits"=>"0", 
"ec_ratio"=>"0", "ec_tenpay_bargainor"=>"", "ec_tenpay_key"=>"", "postappend"=>"1", "editedby"=>"1", "editoroptions"=>"6", 
"edittimelimit"=>"", "exchangemincredits"=>"100", "extcredits"=>{"1"=>{"img"=>"", "title"=>"威望", "unit"=>"", "ratio"=>0, 
"showinthread"=>nil, "allowexchangein"=>nil, "allowexchangeout"=>nil}, "2"=>{"img"=>"", "title"=>"金钱", "unit"=>"", "ratio"=>0, 
"showinthread"=>nil, "allowexchangein"=>nil, "allowexchangeout"=>nil}, "3"=>{"img"=>"", "title"=>"贡献", "unit"=>"", "ratio"=>0, 
"showinthread"=>nil, "allowexchangein"=>nil, "allowexchangeout"=>nil}}, "fastpost"=>"1", "forumallowside"=>"0", "fastsmilies"=>"1", 
"feedday"=>"7", "feedhotday"=>"2", "feedhotmin"=>"3", "feedhotnum"=>"3", "feedmaxnum"=>"100", "showallfriendnum"=>"8", "feedtargetblank"=>"1", 
"floodctrl"=>"15", "forumdomains"=>"a:0:{}", "forumjump"=>"0", "forumlinkstatus"=>"1", "forumseparator"=>"1", "frameon"=>"0", "framewidth"=>"180", 
"friendgroupnum"=>"8", "ftp"=>{"on"=>"0", "ssl"=>"0", "host"=>"", "port"=>"21", "username"=>"", "password"=>"", "pasv"=>"0", "attachdir"=>".", 
"attachurl"=>"/", "timeout"=>"0", "allowedexts"=>"", "disallowedexts"=>"", "minsize"=>"", "hideurl"=>"0", "connid"=>0}, "globalstick"=>"1", 
"targetblank"=>"0", "google"=>"1", "groupstatus"=>"1", "portalstatus"=>"0", "followstatus"=>"0", "collectionstatus"=>"0", "guidestatus"=>"0",
"feedstatus"=>"0", "blogstatus"=>"0", "doingstatus"=>"0", "albumstatus"=>"0", "sharestatus"=>"0", "wallstatus"=>"0", "rankliststatus"=>"0", 
"homestyle"=>"0", "homepagestyle"=>"0", "group_allowfeed"=>"1", "group_admingroupids"=>"a:1:{i:1;s:1:\"1\";}", "group_imgsizelimit"=>"512", 
"group_userperm"=>"a:21:{s:16:\"allowstickthread\";s:1:\"1\";s:15:\"allowbumpthread\";s:1:\"1\";s:20:\"allowhighlightthread\";s:1:\"1\";s:16:\"allowstampthread\";s:1:\"1\";s:16:\"allowclosethread\";s:1:\"1\";s:16:\"allowmergethread\";s:1:\"1\";s:16:\"allowsplitthread\";s:1:\"1\";s:17:\"allowrepairthread\";s:1:\"1\";s:11:\"allowrefund\";s:1:\"1\";s:13:\"alloweditpoll\";s:1:\"1\";s:17:\"allowremovereward\";s:1:\"1\";s:17:\"alloweditactivity\";s:1:\"1\";s:14:\"allowedittrade\";s:1:\"1\";s:17:\"allowdigestthread\";s:1:\"3\";s:13:\"alloweditpost\";s:1:\"1\";s:13:\"allowwarnpost\";s:1:\"1\";s:12:\"allowbanpost\";s:1:\"1\";s:12:\"allowdelpost\";s:1:\"1\";s:13:\"allowupbanner\";s:1:\"1\";s:15:\"disablepostctrl\";s:1:\"0\";s:11:\"allowviewip\";s:1:\"1\";}",
"heatthread"=>{"type"=>"2", "reply"=>5, "recommend"=>3, "period"=>"15", "iconlevels"=>{"2"=>"200", "1"=>"100", "0"=>"50"}}, 
"guide"=>"a:2:{s:5:\"hotdt\";i:604800;s:8:\"digestdt\";i:604800;}", "hideprivate"=>"1", "historyposts"=>"0\t99", "hottopic"=>"10", 
"icp"=>"", "imagelib"=>"0", "imagemaxwidth"=>600, "watermarkminheight"=>"a:3:{s:6:\"portal\";s:1:\"0\";s:5:\"forum\";s:1:\"0\";s:5:\"album\";s:1:\"0\";}", 
"watermarkminwidth"=>"a:3:{s:6:\"portal\";s:1:\"0\";s:5:\"forum\";s:1:\"0\";s:5:\"album\";s:1:\"0\";}", 
"watermarkquality"=>"a:3:{s:6:\"portal\";s:2:\"90\";s:5:\"forum\";i:90;s:5:\"album\";i:90;}", 
"watermarkstatus"=>"a:3:{s:6:\"portal\";s:1:\"0\";s:5:\"forum\";s:1:\"0\";s:5:\"album\";s:1:\"0\";}", 
"watermarktext"=>{"text"=>{"portal"=>"", "forum"=>"", "album"=>""}, "fontpath"=>{"portal"=>"", "forum"=>"", "album"=>""}, 
"size"=>{"portal"=>"", "forum"=>"", "album"=>""}, "angle"=>{"portal"=>"", "forum"=>"", "album"=>""}, "color"=>{"portal"=>"", "forum"=>"", "album"=>""},
"shadowx"=>{"portal"=>"", "forum"=>"", "album"=>""}, "shadowy"=>{"portal"=>"", "forum"=>"", "album"=>""}, "shadowcolor"=>{"portal"=>"", "forum"=>"", "album"=>""}, 
"translatex"=>{"portal"=>"", "forum"=>"", "album"=>""}, "translatey"=>{"portal"=>"", "forum"=>"", "album"=>""}, "skewx"=>{"portal"=>"", "forum"=>"", "album"=>""}, 
"skewy"=>{"portal"=>"", "forum"=>"", "album"=>""}}, "watermarktrans"=>"a:3:{s:6:\"portal\";s:2:\"50\";s:5:\"forum\";i:50;s:5:\"album\";i:50;}", 
"watermarktype"=>{"portal"=>"png", "forum"=>"png", "album"=>"png"}, "indexhot"=>{"status"=>"0", "limit"=>"10", "days"=>"7", 
"expiration"=>"900", "messagecut"=>"200", "width"=>100, "height"=>70}, "indextype"=>"classics", 
"infosidestatus"=>false, "initcredits"=>"0,0,0,0,0,0,0,0,0", "inviteconfig"=>{"invitecodeprompt"=>""}, 
"ipaccess"=>"", "jscachelife"=>"1800", "jsdateformat"=>"", "jspath"=>"static/js/", "jsrefdomains"=>"", "
jsstatus"=>"0", "karmaratelimit"=>"0", "losslessdel"=>"365", "magicdiscount"=>"85", "magicmarket"=>"1", "magicstatus"=>"1", 
"mail"=>"a:10:{s:8:\"mailsend\";s:1:\"1\";s:6:\"server\";s:13:\"smtp.21cn.com\";s:4:\"port\";s:2:\"25\";s:4:\"auth\";s:1:\"1\";s:4:\"from\";s:26:\"Discuz <username@21cn.com>\";s:13:\"auth_username\";s:17:\"username@21cn.com\";s:13:\"auth_password\";s:8:\"password\";s:13:\"maildelimiter\";s:1:\"0\";s:12:\"mailusername\";s:1:\"1\";s:15:\"sendmail_silent\";s:1:\"1\";}", 
"maxavatarpixel"=>"120", "maxavatarsize"=>"20000", "maxbdays"=>"0", "maxchargespan"=>"0", "maxfavorites"=>"100", 
"maxincperthread"=>"0", "maxmagicprice"=>"50", "maxmodworksmonths"=>"3", "maxonlinelist"=>"0", "maxpage"=>"100", 
"maxpolloptions"=>"20", "maxpostsize"=>"10000", "maxsigrows"=>"100", "maxsmilies"=>"10", "membermaxpages"=>"100", "memberperpage"=>"25", 
"memliststatus"=>"1", "memory"=>{"common_member"=>0, "common_member_count"=>0, "common_member_status"=>0, "common_member_profile"=>0, 
"common_member_field_home"=>0, "common_member_field_forum"=>0, "common_member_verify"=>0, "forum_thread"=>172800, 
"forum_thread_forumdisplay"=>300, "forum_collectionrelated"=>0, "forum_postcache"=>300, "forum_collection"=>300, "home_follow"=>86400, 
"forumindex"=>30, "diyblock"=>300, "diyblockoutput"=>30}, "minpostsize"=>"10", "mobile"=>{"allowmobile"=>0, "mobileforward"=>1,
"mobileregister"=>0, "mobilecharset"=>"utf-8", "mobilesimpletype"=>0, "mobiletopicperpage"=>10, "mobilepostperpage"=>5, 
"mobilecachetime"=>0, "mobileforumview"=>0, "mobilepreview"=>1}, "moddisplay"=>"flat", "modratelimit"=>"0", 
"userreasons"=>"很给力!\r\n神马都是浮云\r\n赞一个!\r\n山寨\r\n淡定", "modworkstatus"=>"1", 
"msgforward"=>"a:3:{s:11:\"refreshtime\";i:3;s:5:\"quick\";i:1;s:8:\"messages\";a:14:{i:0;s:19:\"thread_poll_succeed\";i:1;s:19:\"thread_rate_succeed\";i:2;s:23:\"usergroups_join_succeed\";i:3;s:23:\"usergroups_exit_succeed\";i:4;s:25:\"usergroups_update_succeed\";i:5;s:20:\"buddy_update_succeed\";i:6;s:17:\"post_edit_succeed\";i:7;s:18:\"post_reply_succeed\";i:8;s:24:\"post_edit_delete_succeed\";i:9;s:22:\"post_newthread_succeed\";i:10;s:13:\"admin_succeed\";i:11;s:17:\"pm_delete_succeed\";i:12;s:15:\"search_redirect\";i:13;s:10:\"do_success\";}}", 
"msn"=>"", "networkpage"=>"0", "newbiespan"=>"0", "newbietasks"=>"", "newbietaskupdate"=>"", "newspaceavatar"=>"0", "nocacheheaders"=>"0", 
"oltimespan"=>"10", "onlinehold"=>900, "onlinerecord"=>"9\t1347166902", "pollforumid"=>"0", "postbanperiods"=>"", "postmodperiods"=>"", "postperpage"=>"10", 
"privacy"=>{"view"=>{"index"=>0, "friend"=>0, "wall"=>0, "home"=>0, "doing"=>0, "blog"=>0, "album"=>0, "share"=>0}, "feed"=>{"doing"=>1, "blog"=>1, "upload"=>1, "poll"=>1,
"newthread"=>1}}, "pvfrequence"=>"60", "pwdsafety"=>"0", "qihoo"=>{"status"=>0, "searchbox"=>6, "summary"=>1, "jammer"=>1, "maxtopics"=>10, "keywords"=>"", 
"adminemail"=>"", "validity"=>1, "relatedthreads"=>{"bbsnum"=>0, "webnum"=>0, "type"=>{"blog"=>"blog", "news"=>"news", "bbs"=>"bbs"}, "banurl"=>"", "position"=>1, "validity"=>1}}, "ratelogon"=>"1", 
"ratelogrecord"=>"20", "relatenum"=>"10", "relatetime"=>"60", "realname"=>"0", "recommendthread"=>{"allow"=>0}, "regclosemessage"=>"", "regctrl"=>"0", "strongpw"=>false, "regfloodctrl"=>"0",
"regname"=>"register", "reglinkname"=>"立即注册", "regstatus"=>"1", "regverify"=>"0", "relatedtag"=>false, "report_reward"=>"a:2:{s:3:\"min\";i:-3;s:3:\"max\";i:3;}", 
"rewardforumid"=>"0", "rewritecompatible"=>"", "rewritestatus"=>false, "rssstatus"=>"1", "rssttl"=>"60", "runwizard"=>"1", "search"=>{"forum"=>{"status"=>1, 
"searchctrl"=>10, "maxspm"=>10, "maxsearchresults"=>500}}, "group_recommend"=>"a:0:{}", "sphinxon"=>"0", "sphinxhost"=>"", 
"sphinxport"=>"", "sphinxsubindex"=>"threads,threads_mintue", "sphinxmsgindex"=>"posts,posts_minute", "sphinxmaxquerytime"=>"", "sphinxlimit"=>"", "sphinxrank"=>"SPH_RANK_PROXIMITY_BM25", "searchbanperiods"=>"", 
"seccodedata"=>{"minposts"=>"", "loginfailedcount"=>0, "width"=>150, "height"=>40, "type"=>"0", "background"=>"1", "adulterate"=>"1", "ttf"=>"0", "angle"=>"0", 
"color"=>"1", "size"=>"0", "shadow"=>"1", "animator"=>"0"}, "seccodestatus"=>"16", "seclevel"=>"1", "secqaa"=>{"minposts"=>"1", "status"=>0}, "sendmailday"=>"0",
"seodescription"=>false, "seohead"=>"", "seokeywords"=>false, "seotitle"=>{"portal"=>"门户", "forum"=>"论坛", "group"=>"群组", "home"=>"家园", "userapp"=>"应用"}, 
"showavatars"=>"1", "showemail"=>"", "showimages"=>"1", "shownewuser"=>"0", "showsettings"=>"7", "showsignatures"=>"1", "sigviewcond"=>"0", "sitemessage"=>{"time"=>3000,
"register"=>[], "login"=>[], "newthread"=>[], "reply"=>[]}, "sitename"=>"首都师范大学课件交流系统", "siteuniqueid"=>"DXMI1UKOcc889NW2", "siteurl"=>"http://cnu.kejian.tv", 
"smcols"=>"8", "smrows"=>"5", "smthumb"=>"20", "spacedata"=>{"cachelife"=>"900", "limitmythreads"=>"5", "limitmyreplies"=>"5", "limitmyrewards"=>"5",
"limitmytrades"=>"5", "limitmyvideos"=>"0", "limitmyblogs"=>"8", "limitmyfriends"=>"0", "limitmyfavforums"=>"5", "limitmyfavthreads"=>"0", "textlength"=>"300"}, 
"spacestatus"=>"1", "srchhotkeywords"=>["教育心理学\r", "马克思\r", "毛泽东\r", "高等数学\r", "物理\r", "近代史\r", "数学分析\r", "高等代数\r", "大学英语\r", "C语言"], "starthreshold"=>"2", 
"statcode"=>"", "statscachelife"=>"180", "statstatus"=>"", "styleid"=>"1", "stylejump"=>"1", "subforumsindex"=>"0", "tagstatus"=>"1", "taskon"=>"0", 
"tasktypes"=>"a:3:{s:9:\"promotion\";a:2:{s:4:\"name\";s:18:\"网站推广任务\";s:7:\"version\";s:3:\"1.0\";}s:4:\"gift\";a:2:{s:4:\"name\";s:15:\"红包类任务\";s:7:\"version\";s:3:\"1.0\";}s:6:\"avatar\";a:2:{s:4:\"name\";s:15:\"头像类任务\";s:7:\"version\";s:3:\"1.0\";}}", "threadmaxpages"=>"1000",
"threadsticky"=>["全局置顶", "分类置顶", "本版置顶"], "thumbwidth"=>"400", "thumbheight"=>"300", "sourcewidth"=>"0", "sourceheight"=>"0", "thumbquality"=>"100", 
"thumbstatus"=>"", "timeformat"=>"H:i", "timeoffset"=>"8", "topcachetime"=>"60", "topicperpage"=>"20", "tradeforumid"=>"0", "transfermincredits"=>"1000", 
"uc"=>{"addfeed"=>1}, "ucactivation"=>"1", "updatestat"=>"1", "userdateformat"=>"Y-n-j\r\nY/n/j\r\nj-n-Y\r\nj/n/Y", "userstatusby"=>"1", "videophoto"=>"0", 
"video_allowalbum"=>"0", "video_allowblog"=>"0", "video_allowcomment"=>"0", "video_allowdoing"=>"1", "video_allowfriend"=>"1", "video_allowpoke"=>"1", "video_allowshare"=>"0", "video_allowuserapp"=>"0", 
"video_allowviewspace"=>"1", "video_allowwall"=>"1", "viewthreadtags"=>"100", "visitbanperiods"=>"", "visitedforums"=>"10", "vtonlinestatus"=>"1", "wapcharset"=>"0", 
"wapdateformat"=>"n/j", "wapmps"=>"500", "wapppp"=>"5", "wapregister"=>"0", "wapstatus"=>"0", "waptpp"=>"10", "warningexpiration"=>"30", "warninglimit"=>"3", 
"welcomemsg"=>"1", "welcomemsgtitle"=>"{username}，您好，感谢您的注册，请阅读以下内容。", "welcomemsgtxt"=>"尊敬的{username}，您已经注册成为{sitename}的会员，请您在发表言论时，遵守当地法律法规。\r\n如果您有什么疑问可以联系管理员，Email: {adminemail}。\r\n\r\n\r\n{bbname}\r\n{time}", "whosonlinestatus"=>"3", "whosonline_contract"=>"0", "zoomstatus"=>"1", "my_app_status"=>"0",
"my_siteid"=>"", "my_sitekey"=>"", "my_closecheckupdate"=>"", "my_ip"=>"", "my_search_data"=>{"status"=>0, "allow_hot_topic"=>1, "allow_thread_related"=>1, 
"allow_thread_related_bottom"=>0, "allow_forum_recommend"=>1, "allow_forum_related"=>0, "allow_collection_related"=>1, "allow_search_suggest"=>0, "cp_version"=>1, 
"recwords_lifetime"=>21600}, "rewardexpiration"=>"30", "stamplistlevel"=>"3", "visitedthreads"=>"0", "navsubhover"=>"0", "showusercard"=>"1", "allowspacedomain"=>"0",
"allowgroupdomain"=>"0", "holddomain"=>"www|*blog*|*space*|*bbs*", "domain"=>{"defaultindex"=>"forum.php", "holddomain"=>"www|*blog*|*space*|*bbs*", "list"=>[], 
"app"=>{"portal"=>"", "forum"=>"", "group"=>"", "home"=>"", "default"=>""}, "root"=>{"home"=>"", "group"=>"", "forum"=>"", "topic"=>"", "channel"=>""}}, 
"ranklist"=>{"status"=>"1", "cache_time"=>"1", "index_select"=>"thisweek", "member"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, 
"thread"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, "blog"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, 
"poll"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, "activity"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, "picture"=>{"available"=>"1",
"cache_time"=>"5", "show_num"=>"20"}, "forum"=>{"available"=>"1", "cache_time"=>"5", "show_num"=>"20"}, "group"=>{"available"=>"1", "cache_time"=>"5",
"show_num"=>"20"}}, "outlandverify"=>"0", "allowquickviewprofile"=>"1", "allowmoderatingthread"=>"1", "editperdel"=>"1", "defaultindex"=>"forum.php",
"ipregctrltime"=>"72", "verify"=>{"6"=>{"title"=>"实名认证", "available"=>"0", "showicon"=>"0", "viewrealname"=>"0", "field"=>{"realname"=>"realname"}, "icon"=>false}, "enabled"=>false, "1"=>{"icon"=>""}, "2"=>{"icon"=>""}, "3"=>{"icon"=>""}, "4"=>{"icon"=>""}, "5"=>{"icon"=>""}, "7"=>{"title"=>"视频认证", "available"=>"0",
"showicon"=>"0", "viewvideophoto"=>"0", "icon"=>""}}, "focus"=>[], "robotarchiver"=>"0", "profilegroup"=>{"base"=>{"available"=>1, "displayorder"=>0, 
"title"=>"基本资料", "field"=>{"realname"=>"realname", "gender"=>"gender", "birthday"=>"birthday", "birthcity"=>"birthcity", "residecity"=>"residecity", 
"residedist"=>"residedist", "affectivestatus"=>"affectivestatus", "lookingfor"=>"lookingfor", "bloodtype"=>"bloodtype", "field1"=>"field1", "field2"=>"field2", 
"field3"=>"field3", "field4"=>"field4", "field5"=>"field5", "field6"=>"field6", "field7"=>"field7", "field8"=>"field8"}}, "contact"=>{"title"=>"联系方式", 
"available"=>"1", "displayorder"=>"1", "field"=>{"telephone"=>"telephone", "mobile"=>"mobile", "qq"=>"qq", "msn"=>"msn", "taobao"=>"taobao", "icq"=>"icq", "yahoo"=>"yahoo"}}, 
"edu"=>{"available"=>1, "displayorder"=>2, "title"=>"教育情况", "field"=>{"graduateschool"=>"graduateschool", "education"=>"education"}}, 
"work"=>{"available"=>1, "displayorder"=>3, "title"=>"工作情况", "field"=>{"company"=>"company", "occupation"=>"occupation", "position"=>"position", "revenue"=>"revenue"}}, 
"info"=>{"title"=>"个人信息", "available"=>"1", "displayorder"=>"4", "field"=>{"idcardtype"=>"idcardtype", "idcard"=>"idcard", "address"=>"address", "zipcode"=>"zipcode", 
"site"=>"site", "bio"=>"bio", "interest"=>"interest", "sightml"=>"sightml", "customstatus"=>"customstatus", "timeoffset"=>"timeoffset"}}}, "onlyacceptfriendpm"=>"0", 
"pmreportuser"=>"1", "chatpmrefreshtime"=>"8", "preventrefresh"=>"1", "imagelistthumb"=>"0", "regconnect"=>"1", "connect"=>[], "allowwidthauto"=>"1", 
"switchwidthauto"=>"0", "leftsidewidth"=>"130", "card"=>{"open"=>"0"}, "report_receive"=>"a:2:{s:9:\"adminuser\";a:2:{i:0;s:1:\"1\";i:1;s:2:\"35\";}s:12:\"supmoderator\";N;}", 
"leftsideopen"=>"0", "showexif"=>"0", "followretainday"=>"7", "newbie"=>"20", "collectionteamworkernum"=>"3", "collectionnum"=>"10", "blockmaxaggregationitem"=>"20000", "moddetail"=>"0", "homestatus"=>"0", "article_tags"=>{"1"=>"原创", "2"=>"热点", "3"=>"组图", "4"=>"爆料", "5"=>"头条", "6"=>"幻灯", "7"=>"滚动", "8"=>"推荐"}, "upgrade"=>false, "forumpicstyle"=>"a:3:{s:10:\"thumbwidth\";i:0;s:11:\"thumbheight\";i:0;s:8:\"thumbnum\";i:0;}", "thumbsource"=>"0", "portalarticleimgthumbclosed"=>"0", "groupmod"=>"0", "group_description"=>"", "group_keywords"=>"", "forumstickthreads"=>"a:0:{}", "newusergroupid"=>"10", "forumfids"=>[], "version"=>"X2.5", "cachethreadon"=>0, "styles"=>{"1"=>"默认风格"}, "creditnames"=>"1|威望|,2|金钱|,3|贡献|", 
"creditstransextra"=>{"1"=>"2", "2"=>"2", "3"=>"2", "4"=>"2", "5"=>"2", "6"=>"2", "7"=>"2", "8"=>"2", "9"=>"2", "10"=>"2"}, "exchangestatus"=>false, "transferstatus"=>true, 
"ucenterurl"=>"http://uc.kejian.lvh.me", "tradeopen"=>1, "medalstatus"=>1, "specialicon"=>[], "threadplugins"=>[], "hookscriptmobile"=>{"global"=>{"global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_header_mobile"=>[["mobile", "global_header_mobile"]], "global_mobile"=>[["mobile", "global_mobile"]]}}, "common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}}, "forum"=>{"post"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "messagefuncs"=>{"post_mobile"=>[["mobile", "post_mobile_message"]]}}, 
"common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, "global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}, "misc"=>{"mobile"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"mobile"=>[["mobile", "mobile"]]}}, "common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, "global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}}, "hookscript"=>{"global"=>{"common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, "global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}, "forum"=>{"post"=>{"module"=>{"mobile"=>"mobile/mobile"}, 
"adminid"=>{"mobile"=>"0"}, "messagefuncs"=>{"post_mobile"=>[["mobile", "post_mobile_message"]]}}, "common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, "global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}, "misc"=>{"mobile"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"mobile"=>[["mobile", "mobile"]]}}, "common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, "global"=>{"module"=>{"mobile"=>"mobile/mobile"}, 
"adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}, "connect"=>{"login"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "messagefuncs"=>{"login_mobile"=>[["mobile", "login_mobile_message"]]}}, "common"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"common"=>[["mobile", "common"]]}}, "discuzcode"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"discuzcode"=>[["mobile", "discuzcode"]]}}, 
"global"=>{"module"=>{"mobile"=>"mobile/mobile"}, "adminid"=>{"mobile"=>"0"}, "funcs"=>{"global_mobile"=>[["mobile", "global_mobile"]]}}}}, "pluginlinks"=>[],
"plugins"=>{"available"=>["mobile"], "func"=>{"hookscriptmobile"=>{"common"=>true, "discuzcode"=>true}, "hookscript"=>{"common"=>true, "discuzcode"=>true}}, 
"version"=>{"mobile"=>"1.03"}}, "navlogos"=>nil, "navdms"=>[], "navmn"=>{"forum.php"=>"mn_forum", "userapp.php"=>"mn_userapp"}, "navmns"=>{"misc.php"=>[[{"mod"=>"faq"}, "mn_N0a2c"]]}, "menunavs"=>"", "subnavs"=>[], "navs"=>{"2"=>{"navname"=>"论坛", "filename"=>"forum.php", "available"=>"1", "navid"=>"mn_forum", "level"=>"0", "nav"=>"id=\"mn_forum\" ><a href=\"forum.php\" hidefocus=\"true\" title=\"BBS\"  >论坛<span>BBS</span></a"}, 
"5"=>{"navname"=>"游戏", "filename"=>"userapp.php", "available"=>0, "navid"=>"mn_userapp", "level"=>"0", "nav"=>"id=\"mn_userapp\" ><a href=\"userapp.php\" hidefocus=\"true\" title=\"Manyou\"  >游戏<span>Manyou</span></a"}, "6"=>{"navname"=>"插件", "filename"=>"#", "available"=>0}, "7"=>{"navname"=>"帮助", "filename"=>"misc.php?mod=faq", "available"=>"0", "navid"=>"mn_N0a2c", "level"=>"0", "nav"=>"id=\"mn_N0a2c\" ><a href=\"misc.php?mod=faq\" hidefocus=\"true\" title=\"Help\"  >帮助<span>Help</span></a"}}, "footernavs"=>{"stat"=>{"available"=>"1", "navname"=>"站点统计", "code"=>"<a href=\"misc.php?mod=stat\" >站点统计</a>", "type"=>"0", "level"=>"0", "id"=>"stat"}, "report"=>{"available"=>"1", "navname"=>"举报", "code"=>"<a href=\"javascript:;\"  onclick=\"showWindow('miscreport', 'misc.php?mod=report&url='+REPORTURL);return false;\">举报</a>", "type"=>"0", "level"=>"0", "id"=>"report"}, "archiver"=>{"available"=>"1", "navname"=>"Archiver", "code"=>"<a href=\"archiver/\" >Archiver</a>", "type"=>"0", "level"=>"0", "id"=>"archiver"}, "mobile"=>{"available"=>"1", "navname"=>"手机版", "code"=>"<a href=\"forum.php?mobile=yes\" >手机版</a>", "type"=>"0", "level"=>"0", "id"=>"mobile"}},
"spacenavs"=>{"125"=>{"available"=>"1", "navname"=>"{userpanelarea1}", "code"=>"userpanelarea1", "level"=>"0"}, "126"=>{"available"=>"1", "navname"=>"{hr}", "code"=>"</ul><hr class=\"da\" /><ul>", "level"=>"0"}, "127"=>{"available"=>"1", "navname"=>"{userpanelarea2}", "code"=>"userpanelarea2", "level"=>"0"}}, "mynavs"=>{"friend"=>{"available"=>"1", "navname"=>"好友", "code"=>"<a href=\"home.php?mod=space&do=friend\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/friend_b.png) !important\">好友</a>", "level"=>"0"}, "thread"=>{"available"=>"1", "navname"=>"帖子", "code"=>"<a href=\"forum.php?mod=guide&view=my\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/thread_b.png) !important\">帖子</a>", "level"=>"0"}, "favorite"=>{"available"=>"1", "navname"=>"收藏", "code"=>"<a href=\"home.php?mod=space&do=favorite&view=me\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/favorite_b.png) !important\">收藏</a>", "level"=>"0"}, "magic"=>{"available"=>"1", "navname"=>"道具", "code"=>"<a href=\"home.php?mod=magic\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/magic_b.png) !important\">道具</a>", "level"=>"0"}, "medal"=>{"available"=>"1", "navname"=>"勋章", 
"code"=>"<a href=\"home.php?mod=medal\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/medal_b.png) !important\">勋章</a>", "level"=>"0"}, "task"=>{"available"=>"1", "navname"=>"任务", "code"=>"<a href=\"home.php?mod=task\" style=\"background-image:url(http://cnu.kejian.lvh.me/simple/static/image/feed/task_b.png) !important\">任务</a>", "level"=>"0"}}, "topnavs"=>[{"sethomepage"=>{"available"=>"1", 
"navname"=>"设为首页", "code"=>"<a href=\"javascript:;\"  onclick=\"setHomepage('http://cnu.kejian.lvh.me/simple/');\">设为首页</a>", "type"=>"0", "level"=>"0", "id"=>"sethomepage"}, "setfavorite"=>{"available"=>"1", "navname"=>"收藏本站", "code"=>"<a href=\"http://cnu.kejian.lvh.me/simple/\"  onclick=\"addFavorite(this.href, '首都师范大学课件交流系统');return false;\">收藏本站</a>", "type"=>"0", "level"=>"0", "id"=>"setfavorite"}}], "allowsynlogin"=>1, "ucappopen"=>{"OTHER"=>1}, "ucapp"=>[], "uchomeurl"=>"", "discuzurl"=>"http://cnu.kejian.lvh.me/simple", "homeshow"=>"0", "reginput"=>{"username"=>"0Or618", "password"=>"XCsb57", "password2"=>"vSjFbB", "email"=>"octFfT"}, "output"=>{"str"=>[], "preg"=>[]}}, "member"=>{"uid"=>"35", "email"=>"llb0536@gmail.com", "username"=>"libo-liu", "password"=>"8cb16afbdd887459b90d5896c622349f", "status"=>"0", "emailstatus"=>"0", "avatarstatus"=>"1", "videophotostatus"=>"0", "adminid"=>"1", "groupid"=>"1", "groupexpiry"=>"0", "extgroupids"=>"", "regdate"=>"1346597125", "credits"=>"31", "notifysound"=>"0", "timeoffset"=>"8", "newpm"=>"0", "newprompt"=>"0", 
"accessmasks"=>"0", "allowadmincp"=>"1", "onlyacceptfriendpm"=>"0", "conisbind"=>"0", "lastvisit"=>"1349512397", "regip"=>"106.187.96.204", "lastip"=>"127.0.0.1", "lastactivity"=>"1349512181", "lastpost"=>"1347679420", "lastsendmail"=>"0", "invisible"=>"0", 
"buyercredit"=>"0", "sellercredit"=>"0", "favtimes"=>"0", "sharetimes"=>"0", "profileprogress"=>"0"}, "group"=>{"groupid"=>"1", "radminid"=>"1", "grouptitle"=>"管理员", "stars"=>"9", "color"=>"", "icon"=>"", "allowvisit"=>"2", "allowsendpm"=>"1", "allowinvite"=>"1", "allowmailinvite"=>"1", "maxinvitenum"=>"0", "inviteprice"=>"0", "maxinviteday"=>"10", "readaccess"=>"200", "allowpost"=>"1", "allowreply"=>"1", "allowpostpoll"=>"1", "allowpostreward"=>"1", "allowposttrade"=>"1", "allowpostactivity"=>"1", "allowdirectpost"=>"3", "allowgetattach"=>"1", "allowgetimage"=>"1", "allowpostattach"=>"1", "allowpostimage"=>"1", "allowvote"=>"1", "allowsearch"=>"127", "allowcstatus"=>"1", "allowinvisible"=>"1", "allowtransfer"=>"1", "allowsetreadperm"=>"1", "allowsetattachperm"=>"1", "allowposttag"=>"1", "allowhidecode"=>"1", "allowhtml"=>"1", "allowanonymous"=>"1", "allowsigbbcode"=>"1", "allowsigimgcode"=>"1", "allowmagics"=>"2", "disableperiodctrl"=>"1", "reasonpm"=>"0", "maxprice"=>"30", "maxsigsize"=>"500", "maxattachsize"=>"204800000", "maxsizeperday"=>"0", "maxthreadsperhour"=>"0", "maxpostsperhour"=>"0", "attachextensions"=>"", "raterange"=>[], "mintradeprice"=>"1", "maxtradeprice"=>"0", "minrewardprice"=>"1", "maxrewardprice"=>"0", "magicsdiscount"=>"0", "maxmagicsweight"=>"200", "allowpostdebate"=>"1", "tradestick"=>"5", "exempt"=>"255", "maxattachnum"=>"0", "allowposturl"=>"3", "allowrecommend"=>"1", "allowpostrushreply"=>"1", "maxfriendnum"=>"0", "maxspacesize"=>0, "allowcomment"=>"1", 
"allowcommentarticle"=>"1000", "searchinterval"=>"0", "searchignore"=>"0", "allowblog"=>"1", "allowdoing"=>"1", "allowupload"=>"1", "allowshare"=>"1", "allowblogmod"=>"0", "allowdoingmod"=>"0", "allowuploadmod"=>"0", "allowsharemod"=>"0", "allowcss"=>"0", "allowpoke"=>"1", "allowfriend"=>"1", "allowclick"=>"1", "allowmagic"=>"0", "allowstat"=>"1", "allowstatdata"=>"1", "videophotoignore"=>"1", "allowviewvideophoto"=>"1", "allowmyop"=>"1", "magicdiscount"=>"0", "domainlength"=>"5", "seccode"=>"1", "disablepostctrl"=>"1", "allowbuildgroup"=>"30", "allowgroupdirectpost"=>"3", "allowgroupposturl"=>"3", "edittimelimit"=>"0", "allowpostarticle"=>"1", "allowdownlocalimg"=>"1", "allowdownremoteimg"=>"1", "allowpostarticlemod"=>"0", "allowspacediyhtml"=>"1", "allowspacediybbcode"=>"1",
"allowspacediyimgcode"=>"1", "allowcommentpost"=>"3", "allowcommentitem"=>"1", "allowcommentreply"=>"0", "allowreplycredit"=>"1", "ignorecensor"=>"1", 
"allowsendallpm"=>"1", "allowsendpmmaxnum"=>"0", "maximagesize"=>"0", "allowmediacode"=>"1", "allowat"=>"50", "allowsetpublishdate"=>"0", "allowfollowcollection"=>"30", "allowcommentcollection"=>"1", "allowcreatecollection"=>"5", "alloweditpost"=>"1", "alloweditpoll"=>"1", "allowstickthread"=>"3", "allowmodpost"=>"1", "allowdelpost"=>"1", "allowmassprune"=>"1", "allowrefund"=>"1", "allowcensorword"=>"1", "allowviewip"=>"1", "allowbanip"=>"1", "allowedituser"=>"1", "allowmoduser"=>"1", "allowbanuser"=>"1", "allowbanvisituser"=>"1", "allowpostannounce"=>"1", "allowviewlog"=>"1", "allowbanpost"=>"1", "supe_allowpushthread"=>"1", "allowhighlightthread"=>"1", "allowdigestthread"=>"3", "allowrecommendthread"=>"1", "allowbumpthread"=>"1", "allowclosethread"=>"1", "allowmovethread"=>"1", "allowedittypethread"=>"1", 
"allowstampthread"=>"1", "allowstamplist"=>"1", "allowcopythread"=>"1", "allowmergethread"=>"1", "allowsplitthread"=>"1", "allowrepairthread"=>"1", "allowwarnpost"=>"1", "allowviewreport"=>"1", "alloweditforum"=>"1", "allowremovereward"=>"1", "allowedittrade"=>"1", "alloweditactivity"=>"1", "allowstickreply"=>"1", "allowmanagearticle"=>"1", "allowaddtopic"=>"1", "allowmanagetopic"=>"1", "allowdiy"=>"1", "allowclearrecycle"=>"1", "allowmanagetag"=>"1", "alloweditusertag"=>"0", "managefeed"=>"1", "managedoing"=>"1",
"manageshare"=>"1", "manageblog"=>"1", "managealbum"=>"1", "managecomment"=>"1", "managemagiclog"=>"1",
"managereport"=>"1", "managehotuser"=>"1", "managedefaultuser"=>"1", "managevideophoto"=>"1", "managemagic"=>"1", "manageclick"=>"1", "allowmanagecollection"=>"1", "grouptype"=>"system", "grouppublic"=>false, "groupcreditshigher"=>"0", "groupcreditslower"=>"0", "allowthreadplugin"=>[], "plugin"=>nil}, 
"cookie"=>{"checkpatch"=>"1", "saltkey"=>"SY3sC6g9", "lastvisit"=>"1349314716", "sid"=>"co6B65", "lastact"=>"1349512472\ttouch.php\t", "auth"=>"91ccLwUNMcMh8pLIU+Mmg3WxNqgJbJBINKVnBvP1ii6fTKRNKrRyRLhv5/AO/o6QtId4rHap+xoK9u2ROtkKCA==", "creditnotice"=>"0D0D2D0D0D0D0D0D0D35", "creditbase"=>"0D0D28D0D0D0D0D0D0", "creditrule"=>"%E6%AF%8F%E5%A4%A9%E7%99%BB%E5%BD%95", "ulastactivity"=>"d8e6NcwCwvXqlgcAxsYHH87lvaUGFRH8vSv8sAAyWKxX7vGa1AIg"}, "style"=>{"styleid"=>"1", "name"=>"默认风格", "available"=>"", "templateid"=>"1", "extstyle"=>[["./template/default/style/t1", "红", "#BA350F"], ["./template/default/style/t2", "青", "#429296"], ["./template/default/style/t3", "橙", "#FE9500"], ["./template/default/style/t4", "紫", "#9934B7"], ["./template/default/style/t5", "蓝", "#0053B9"]], "tplname"=>"默认模板套系", "directory"=>"./template/default", "copyright"=>"北京康盛新创科技有限责任公司", "tpldir"=>"./template/default", "menuhoverbgcolor"=>"#005AB4", "lightlink"=>"#FFF", "floatbgcolor"=>"#FFF", "dropmenubgcolor"=>"#FEFEFE", "floatmaskbgcolor"=>"#000", "dropmenuborder"=>"#DDD", "specialbg"=>"#E5EDF2", "specialborder"=>"#C2D5E3", "commonbg"=>"#F2F2F2", "commonborder"=>"#CDCDCD", "inputbg"=>"#FFF", "stypeid"=>"1", "inputborderdarkcolor"=>"#848484", "headerbgcolor"=>"", "headerborder"=>"0", "sidebgcolor"=>"", "msgfontsize"=>"14px", "bgcolor"=>"#FFF", "noticetext"=>"#F26C4F", "highlightlink"=>"#369", "link"=>"#333", "lighttext"=>"#999", "midtext"=>"#666", 
"tabletext"=>"#444", "smfontsize"=>"0.83em", "threadtitlefont"=>"Tahoma,Helvetica,'SimSun',sans-serif", "threadtitlefontsize"=>"14px", "smfont"=>"Tahoma,Helvetica,sans-serif", "titlebgcolor"=>"#E5EDF2", "fontsize"=>"12px/1.5", "font"=>"Tahoma,Helvetica,'SimSun',sans-serif", "styleimgdir"=>"static/image/common", "imgdir"=>"static/image/common", "boardimg"=>"static/image/common/logo.png", "headertext"=>"#444", "footertext"=>"#666", "menubgcolor"=>"#2B7ACD", "menutext"=>"#FFF", "menuhovertext"=>"#FFF", "wrapbg"=>"#FFF", "wrapbordercolor"=>"#CCC", "contentwidth"=>"630px", "contentseparate"=>"#C2D5E3", "inputborder"=>"#E0E0E0", "menuhoverbgcode"=>"background: #005AB4 url(\"static/image/common/nv_a.png\") no-repeat 50% -33px", "floatbgcode"=>"background: #FFF", "dropmenubgcode"=>"background: #FEFEFE", "floatmaskbgcode"=>"background: #000", "headerbgcode"=>"", "sidebgcode"=>"background: url(\"static/image/common/vlineb.png\") repeat-y 0 0", "bgcode"=>"background: #FFF url(\"static/image/common/background.png\") repeat-x 0 0", "titlebgcode"=>"background: #E5EDF2 url(\"static/image/common/titlebg.png\") repeat-x 0 0", "menubgcode"=>"background: #2B7ACD url(\"static/image/common/nv.png\") no-repeat 0 0", "boardlogo"=>"<img src=\"static/image/common/logo.png\" alt=\"首都师范大学课件交流系统\" border=\"0\" />", "bold"=>"bold", "defaultextstyle"=>"", "verhash"=>"Gx5"}, "cache"=>{"cronnextrun"=>"1349514000", "style_default"=>{"styleid"=>"1", "name"=>"默认风格", "available"=>"", "templateid"=>"1", "extstyle"=>[["./template/default/style/t1", "红", "#BA350F"], ["./template/default/style/t2", "青", "#429296"], ["./template/default/style/t3", "橙", "#FE9500"], ["./template/default/style/t4", "紫", "#9934B7"], ["./template/default/style/t5", "蓝", "#0053B9"]], "tplname"=>"默认模板套系", "directory"=>"./template/default", "copyright"=>"北京康盛新创科技有限责任公司", "tpldir"=>"./template/default", "menuhoverbgcolor"=>"#005AB4", "lightlink"=>"#FFF", "floatbgcolor"=>"#FFF", "dropmenubgcolor"=>"#FEFEFE", "floatmaskbgcolor"=>"#000", "dropmenuborder"=>"#DDD", "specialbg"=>"#E5EDF2", "specialborder"=>"#C2D5E3", "commonbg"=>"#F2F2F2", "commonborder"=>"#CDCDCD", "inputbg"=>"#FFF", "stypeid"=>"1", "inputborderdarkcolor"=>"#848484", "headerbgcolor"=>"", "headerborder"=>"0", "sidebgcolor"=>"", "msgfontsize"=>"14px", "bgcolor"=>"#FFF", "noticetext"=>"#F26C4F", "highlightlink"=>"#369", "link"=>"#333", "lighttext"=>"#999", "midtext"=>"#666", "tabletext"=>"#444", "smfontsize"=>"0.83em", "threadtitlefont"=>"Tahoma,Helvetica,'SimSun',sans-serif", "threadtitlefontsize"=>"14px", "smfont"=>"Tahoma,Helvetica,sans-serif", "titlebgcolor"=>"#E5EDF2", "fontsize"=>"12px/1.5", "font"=>"Tahoma,Helvetica,'SimSun',sans-serif", "styleimgdir"=>"static/image/common", "imgdir"=>"static/image/common", "boardimg"=>"static/image/common/logo.png", "headertext"=>"#444", "footertext"=>"#666", "menubgcolor"=>"#2B7ACD", "menutext"=>"#FFF", "menuhovertext"=>"#FFF", "wrapbg"=>"#FFF", "wrapbordercolor"=>"#CCC", "contentwidth"=>"630px", "contentseparate"=>"#C2D5E3", "inputborder"=>"#E0E0E0", "menuhoverbgcode"=>"background: #005AB4 url(\"static/image/common/nv_a.png\") no-repeat 50% -33px", "floatbgcode"=>"background: #FFF", "dropmenubgcode"=>"background: #FEFEFE", "floatmaskbgcode"=>"background: #000", "headerbgcode"=>"", "sidebgcode"=>"background: url(\"static/image/common/vlineb.png\") repeat-y 0 0", "bgcode"=>"background: #FFF url(\"static/image/common/background.png\") repeat-x 0 0", "titlebgcode"=>"background: #E5EDF2 url(\"static/image/common/titlebg.png\") repeat-x 0 0", "menubgcode"=>"background: #2B7ACD url(\"static/image/common/nv.png\") no-repeat 0 0", 
"boardlogo"=>"<img src=\"static/image/common/logo.png\" alt=\"首都师范大学课件交流系统\" border=\"0\" />", "bold"=>"bold", "defaultextstyle"=>"", "verhash"=>"Gx5"}, "usergroup_1"=>{"groupid"=>"1", "radminid"=>"1", "grouptitle"=>"管理员", "stars"=>"9", "color"=>"", "icon"=>"", "allowvisit"=>"2", "allowsendpm"=>"1", "allowinvite"=>"1", "allowmailinvite"=>"1", "maxinvitenum"=>"0",
"inviteprice"=>"0", "maxinviteday"=>"10", "readaccess"=>"200", "allowpost"=>"1", "allowreply"=>"1", "allowpostpoll"=>"1", 
"allowpostreward"=>"1", "allowposttrade"=>"1", "allowpostactivity"=>"1", "allowdirectpost"=>"3", "allowgetattach"=>"1", "allowgetimage"=>"1", "allowpostattach"=>"1", "allowpostimage"=>"1", "allowvote"=>"1", "allowsearch"=>"127", "allowcstatus"=>"1", "allowinvisible"=>"1", "allowtransfer"=>"1", "allowsetreadperm"=>"1", "allowsetattachperm"=>"1", "allowposttag"=>"1", "allowhidecode"=>"1", "allowhtml"=>"1", "allowanonymous"=>"1", "allowsigbbcode"=>"1", "allowsigimgcode"=>"1", "allowmagics"=>"2", "disableperiodctrl"=>"1", "reasonpm"=>"0", "maxprice"=>"30", "maxsigsize"=>"500", "maxattachsize"=>"204800000", "maxsizeperday"=>"0", "maxthreadsperhour"=>"0", "maxpostsperhour"=>"0", "attachextensions"=>"", "raterange"=>[], "mintradeprice"=>"1", "maxtradeprice"=>"0", "minrewardprice"=>"1", "maxrewardprice"=>"0", "magicsdiscount"=>"0", "maxmagicsweight"=>"200", "allowpostdebate"=>"1", "tradestick"=>"5", "exempt"=>"255", "maxattachnum"=>"0", "allowposturl"=>"3", "allowrecommend"=>"1", "allowpostrushreply"=>"1", "maxfriendnum"=>"0", "maxspacesize"=>0, "allowcomment"=>"1", "allowcommentarticle"=>"1000", "searchinterval"=>"0", "searchignore"=>"0", "allowblog"=>"1", "allowdoing"=>"1", "allowupload"=>"1", "allowshare"=>"1", "allowblogmod"=>"0", "allowdoingmod"=>"0", "allowuploadmod"=>"0", "allowsharemod"=>"0", "allowcss"=>"0", "allowpoke"=>"1", "allowfriend"=>"1", "allowclick"=>"1", "allowmagic"=>"0", "allowstat"=>"1", "allowstatdata"=>"1", "videophotoignore"=>"1", "allowviewvideophoto"=>"1", "allowmyop"=>"1", "magicdiscount"=>"0", "domainlength"=>"5", "seccode"=>"1", "disablepostctrl"=>"1", "allowbuildgroup"=>"30", "allowgroupdirectpost"=>"3", "allowgroupposturl"=>"3", "edittimelimit"=>"0", "allowpostarticle"=>"1", "allowdownlocalimg"=>"1", "allowdownremoteimg"=>"1", "allowpostarticlemod"=>"0", "allowspacediyhtml"=>"1", "allowspacediybbcode"=>"1", "allowspacediyimgcode"=>"1", "allowcommentpost"=>"3", "allowcommentitem"=>"1", "allowcommentreply"=>"0", "allowreplycredit"=>"1", "ignorecensor"=>"1", "allowsendallpm"=>"1", "allowsendpmmaxnum"=>"0", "maximagesize"=>"0", "allowmediacode"=>"1", "allowat"=>"50", "allowsetpublishdate"=>"0", "allowfollowcollection"=>"30", "allowcommentcollection"=>"1", "allowcreatecollection"=>"5", "alloweditpost"=>"1", "alloweditpoll"=>"1", "allowstickthread"=>"3", "allowmodpost"=>"1", "allowdelpost"=>"1", "allowmassprune"=>"1", "allowrefund"=>"1", "allowcensorword"=>"1", "allowviewip"=>"1", "allowbanip"=>"1", "allowedituser"=>"1", "allowmoduser"=>"1", "allowbanuser"=>"1", "allowbanvisituser"=>"1", "allowpostannounce"=>"1", "allowviewlog"=>"1", "allowbanpost"=>"1", "supe_allowpushthread"=>"1", "allowhighlightthread"=>"1", "allowdigestthread"=>"3", "allowrecommendthread"=>"1", "allowbumpthread"=>"1", "allowclosethread"=>"1", "allowmovethread"=>"1", "allowedittypethread"=>"1", "allowstampthread"=>"1", "allowstamplist"=>"1", "allowcopythread"=>"1", "allowmergethread"=>"1", "allowsplitthread"=>"1", "allowrepairthread"=>"1", "allowwarnpost"=>"1", "allowviewreport"=>"1", "alloweditforum"=>"1", "allowremovereward"=>"1", "allowedittrade"=>"1", "alloweditactivity"=>"1", "allowstickreply"=>"1", "allowmanagearticle"=>"1", "allowaddtopic"=>"1", "allowmanagetopic"=>"1", "allowdiy"=>"1", "allowclearrecycle"=>"1", "allowmanagetag"=>"1", "alloweditusertag"=>"0", "managefeed"=>"1", "managedoing"=>"1", "manageshare"=>"1", "manageblog"=>"1", "managealbum"=>"1", "managecomment"=>"1", "managemagiclog"=>"1", "managereport"=>"1", 
"managehotuser"=>"1", "managedefaultuser"=>"1", "managevideophoto"=>"1", "managemagic"=>"1", "manageclick"=>"1", "allowmanagecollection"=>"1", "grouptype"=>"system", "grouppublic"=>false, "groupcreditshigher"=>"0", "groupcreditslower"=>"0", "allowthreadplugin"=>[], "plugin"=>nil}, "ipbanned"=>[], "creditrule"=>{"followedcollection"=>{"rid"=>"31", "rulename"=>"淘专辑被订阅", "action"=>"followedcollection", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"3", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%B7%98%E4%B8%93%E8%BE%91%E8%A2%AB%E8%AE%A2%E9%98%85"}, "portalcomment"=>{"rid"=>"30", "rulename"=>"文章评论", "action"=>"portalcomment", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"40", "norepeat"=>"1", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%96%87%E7%AB%A0%E8%AF%84%E8%AE%BA"}, "modifydomain"=>{"rid"=>"29", "rulename"=>"修改域名", "action"=>"modifydomain", "cycletype"=>"0", "cycletime"=>"0", "rewardnum"=>"1", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E4%BF%AE%E6%94%B9%E5%9F%9F%E5%90%8D"}, "click"=>{"rid"=>"28", "rulename"=>"信息表态", "action"=>"click", 
"cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"10", "norepeat"=>"1", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E4%BF%A1%E6%81%AF%E8%A1%A8%E6%80%81"}, "useapp"=>{"rid"=>"27", "rulename"=>"使用应用", "action"=>"useapp", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"10", "norepeat"=>"3", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E4%BD%BF%E7%94%A8%E5%BA%94%E7%94%A8"}, "installapp"=>{"rid"=>"26", "rulename"=>"安装应用", "action"=>"installapp", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"3", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%AE%89%E8%A3%85%E5%BA%94%E7%94%A8"}, "getcomment"=>{"rid"=>"25", "rulename"=>"被评论", "action"=>"getcomment", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"20", "norepeat"=>"1", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%A2%AB%E8%AF%84%E8%AE%BA"}, "comment"=>{"rid"=>"24", "rulename"=>"评论", "action"=>"comment", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"40", "norepeat"=>"1", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%AF%84%E8%AE%BA"}, "createshare"=>{"rid"=>"23", "rulename"=>"发起分享", "action"=>"createshare", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"3", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"1", 
"extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E8%B5%B7%E5%88%86%E4%BA%AB"}, 
"joinpoll"=>{"rid"=>"22", "rulename"=>"参与投票", "action"=>"joinpoll", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"10", 
"norepeat"=>"1", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%82%E4%B8%8E%E6%8A%95%E7%A5%A8"}, "publishblog"=>{"rid"=>"21", "rulename"=>"发表日志", "action"=>"publishblog", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"3", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E8%A1%A8%E6%97%A5%E5%BF%97"}, "doing"=>{"rid"=>"20", "rulename"=>"发表记录", "action"=>"doing", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"5", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E8%A1%A8%E8%AE%B0%E5%BD%95"}, "getguestbook"=>{"rid"=>"19", "rulename"=>"被留言", "action"=>"getguestbook", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"5", "norepeat"=>"2", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%A2%AB%E7%95%99%E8%A8%80"}, "guestbook"=>{"rid"=>"18", "rulename"=>"留言", "action"=>"guestbook", 
"cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"20", "norepeat"=>"2", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E7%95%99%E8%A8%80"}, "poke"=>{"rid"=>"17", "rulename"=>"打招呼", "action"=>"poke", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"10", "norepeat"=>"2", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%89%93%E6%8B%9B%E5%91%BC"}, "visit"=>{"rid"=>"16", "rulename"=>"访问别人空间", "action"=>"visit", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"10", "norepeat"=>"2", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%AE%BF%E9%97%AE%E5%88%AB%E4%BA%BA%E7%A9%BA%E9%97%B4"}, "daylogin"=>{"rid"=>"15", "rulename"=>"每天登录", "action"=>"daylogin", "cycletype"=>"1", "cycletime"=>"0", "rewardnum"=>"1", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%AF%8F%E5%A4%A9%E7%99%BB%E5%BD%95"}, "hotinfo"=>{"rid"=>"14", "rulename"=>"热点信息", "action"=>"hotinfo", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E7%83%AD%E7%82%B9%E4%BF%A1%E6%81%AF"}, "videophoto"=>{"rid"=>"13", "rulename"=>"视频认证", "action"=>"videophoto", "cycletype"=>"0", "cycletime"=>"0", "rewardnum"=>"1", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"10", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%A7%86%E9%A2%91%E8%AE%A4%E8%AF%81"}, "setavatar"=>{"rid"=>"12", "rulename"=>"设置头像", "action"=>"setavatar", "cycletype"=>"0", "cycletime"=>"0", "rewardnum"=>"1", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"5", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%AE%BE%E7%BD%AE%E5%A4%B4%E5%83%8F"}, "realemail"=>{"rid"=>"11", "rulename"=>"邮箱认证", "action"=>"realemail", "cycletype"=>"0", "cycletime"=>"0", "rewardnum"=>"1", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"10", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E9%82%AE%E7%AE%B1%E8%AE%A4%E8%AF%81"}, "tradefinished"=>{"rid"=>"10", "rulename"=>"成功交易", "action"=>"tradefinished", 
"cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%88%90%E5%8A%9F%E4%BA%A4%E6%98%93"}, "promotion_register"=>{"rid"=>"9", "rulename"=>"注册推广", "action"=>"promotion_register", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%B3%A8%E5%86%8C%E6%8E%A8%E5%B9%BF"}, "promotion_visit"=>{"rid"=>"8", "rulename"=>"访问推广", "action"=>"promotion_visit", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E8%AE%BF%E9%97%AE%E6%8E%A8%E5%B9%BF"}, "search"=>{"rid"=>"7", "rulename"=>"搜索", "action"=>"search", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E6%90%9C%E7%B4%A2"}, "sendpm"=>{"rid"=>"6", "rulename"=>"发短消息", "action"=>"sendpm", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E7%9F%AD%E6%B6%88%E6%81%AF"}, "getattach"=>{"rid"=>"5", "rulename"=>"下载附件", "action"=>"getattach", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E4%B8%8B%E8%BD%BD%E9%99%84%E4%BB%B6"}, "postattach"=>{"rid"=>"4", "rulename"=>"上传附件", "action"=>"postattach", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"0", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E4%B8%8A%E4%BC%A0%E9%99%84%E4%BB%B6"}, "digest"=>{"rid"=>"3", "rulename"=>"加精华", "action"=>"digest", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"5", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", 
"rulenameuni"=>"%E5%8A%A0%E7%B2%BE%E5%8D%8E"}, "reply"=>{"rid"=>"2", "rulename"=>"发表回复", "action"=>"reply", "cycletype"=>"4", 
"cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"1", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E8%A1%A8%E5%9B%9E%E5%A4%8D"}, "post"=>{"rid"=>"1", "rulename"=>"发表主题", "action"=>"post", "cycletype"=>"4", "cycletime"=>"0", "rewardnum"=>"0", "norepeat"=>"0", "extcredits1"=>"0", "extcredits2"=>"2", "extcredits3"=>"0", "extcredits4"=>"0", "extcredits5"=>"0", "extcredits6"=>"0", "extcredits7"=>"0", "extcredits8"=>"0", "fids"=>"", "rulenameuni"=>"%E5%8F%91%E8%A1%A8%E4%B8%BB%E9%A2%98"}}}, "session"=>{"sid"=>"co6B65", "ip1"=>"127", "ip2"=>"0", "ip3"=>"0", "ip4"=>"1", "uid"=>"35", "username"=>"", "groupid"=>7, "invisible"=>"0", "action"=>0, "lastactivity"=>1349512472, "fid"=>0, "tid"=>0, "lastolupdate"=>0}, "lang"=>{"core"=>{"nextpage"=>"下一页", "prevpage"=>"上一页", "pageunit"=>"页", "total"=>"共", "10k"=>"万", "pagejumptip"=>"输入页码，按回车快速跳转", "date"=>{"before"=>"前", "day"=>"天", "yday"=>"昨天", "byday"=>"前天", "hour"=>"小时", "half"=>"半", "min"=>"分钟", "sec"=>"秒", "now"=>"刚刚"}, "yes"=>"是", "no"=>"否", "weeks"=>{"1"=>"周一", "2"=>"周二", "3"=>"周三", "4"=>"周四", "5"=>"周五", "6"=>"周六", "7"=>"周日"}, "dot"=>"、", "archive"=>"存档", "portal"=>"门户", "end"=>"末尾", "seccode_image_tips"=>"输入下图中的字符<br />", "seccode_image_ani_tips"=>"请输入下面动画图片中的字符<br />", "seccode_sound_tips"=>"输入您听到的字符<br />", "secqaa_tips"=>"输入下面问题的答案<br />", "fullblankspace"=>"　", "title_goruptype"=>"类", "title_of"=>"的", "title_board_message"=>"提示信息", "title_view_all"=>"随便看看", "title_activity"=>"活动", "title_friend_activity"=>"好友发起的活动", "title_my_activity"=>"我的活动", "title_newest_activity"=>"最新活动", "title_top_activity"=>"热门活动", "title_album"=>"相册", "title_friend_album"=>"好友的相册", "title_my_album"=>"我的相册", "title_newest_update_album"=>"最新更新的相册", "title_hot_pic_recommend"=>"热门图片推荐", "title_blog"=>"日志", "title_friend_blog"=>"好友的日志", "title_my_blog"=>"我的日志", "title_post_new_blog"=>"发表新日志", "title_newest_blog"=>"最新发表的日志", "title_recommend_blog"=>"推荐阅读的日志", "title_debate"=>"辩论", "title_friend_debate"=>"好友发起的辩论", "title_my_debate"=>"我的辩论", "title_create_new_debate"=>"发起新辩论", "title_my_create_debate"=>"我发起的辩论", "title_my_join_debate"=>"我参与的辩论", "title_newest_debate"=>"最新辩论", "title_top_debate"=>"热门辩论", "title_doing"=>"记录", "title_newest_doing"=>"记录", "title_me_friend_doing"=>"我和好友的记录", "title_doing_view_me"=>"我的记录", "title_thread_favorite"=>"课件收藏", "title_forum_favorite"=>"课件收藏", "title_group_favorite"=>"{gorup}收藏", "title_blog_favorite"=>"日志收藏", "title_album_favorite"=>"相册收藏", "title_article_favorite"=>"文章收藏", "title_all_favorite"=>"全部收藏", "title_friend_list"=>"好友列表", "title_all_poll"=>"随便看看投票", "title_we_poll"=>"好友发起的投票", "title_me_poll"=>"我的投票", "title_hot_poll"=>"热门投票", "title_dateline_poll"=>"最新投票", "title_all_reward"=>"随便看看悬赏", "title_we_reward"=>"好友发起的悬赏", "title_me_reward"=>"我的悬赏", "title_hot_reward"=>"热门悬赏", "title_dateline_reward"=>"最新悬赏", "title_share_all"=>"全部", "title_share_link"=>"网址", "title_share_video"=>"视频", "title_share_music"=>"音乐", "title_share_flash"=>"Flash", "title_share_poll"=>"投票", "title_share_pic"=>"图片", "title_share_album"=>"相册", "title_share_blog"=>"日志", "title_share_space"=>"用户", "title_share_thread"=>"课件", "title_share_article"=>"文章", "title_share_tag"=>"TAG", "title_share"=>"分享", "title_thread"=>"课件", "title_all_thread"=>"随便看看课件", "title_we_thread"=>"好友发起的课件", "title_me_thread"=>"我的课件", "title_hot_thread"=>"热门课件", 
"title_dateline_thread"=>"最新课件", "title_trade"=>"商品", "title_all_trade"=>"随便看看商品", "title_we_trade"=>"好友出售的商品", "title_me_trade"=>"我的商品", 
"title_hot_trade"=>"热门商品", "title_dateline_trade"=>"最新商品", "title_tradelog_trade"=>"交易记录", "title_eccredit_trade"=>"信用评价", "title_credit"=>"积分", 
"title_friend_add"=>"添加好友", "title_people_might_know"=>"可能认识的人", "title_friend_request"=>"好友请求", "title_search_friend"=>"查找好友", "title_invite_friend"=>"邀请好友", "title_password_security"=>"密码安全", "title_flash_upload"=>"批量上传", "title_cam_upload"=>"大头贴", "title_normal_upload"=>"普通上传", "title_newthread_post"=>"上传课件", "title_reply_post"=>"评论课件", "title_edit_post"=>"编辑课件", "title_newtrade_post"=>"发布商品", "title_magics_shop"=>"道具商店", 
"title_magics_hot"=>"热销道具", "title_magics_user"=>"我的道具", "title_magics_log"=>"道具记录", "title_medals_list"=>"勋章", "title_setup"=>"设置", "title_memcp_blog"=>"发表日志", "title_memcp_upload"=>"上传", "title_memcp_share"=>"添加分享", "title_memcp_sendmail"=>"邮件提醒", "title_memcp_privacy"=>"隐私筛选", "title_memcp_avatar"=>"修改头像", "title_memcp_profile"=>"个人资料", "title_memcp_credit"=>"积分", "title_memcp_friend"=>"好友", "title_memcp_usergroup"=>"用户组", "title_memcp_album"=>"编辑相册", "title_memcp_poke"=>"打招呼", "title_memcp_videophoto"=>"视频认证", "title_memcp_comment"=>"评论", "title_memcp_eccredit"=>"信用评价", "title_memcp_promotion"=>"访问推广", "title_task"=>"任务", "title_login"=>"登录", "title_ranklist_picture"=>"图片排行", "title_ranklist_member"=>"用户排行", "title_ranklist_thread"=>"课件排行", "title_ranklist_blog"=>"日志排行", "title_ranklist_poll"=>"投票排行", "title_ranklist_activity"=>"活动排行", "title_ranklist_forum"=>"课程排行", "title_ranklist_group"=>"群组排行", "title_ranklist_app"=>"应用排行", "title_ranklist_index"=>"全部排行", "title_ranklist_rankname"=>"排行榜", "title_search"=>"搜索", "title_topic_management"=>"创建专题", "title_portal_management"=>"门户管理", "title_portalblock_management"=>"模块管理", "title_block_management"=>"模块管理", "title_blockdata_management"=>"推送审核", "title_index_management"=>"频道栏目", "title_article_management"=>"发布文章", 
"title_category_management"=>"管理文章", "title_stats"=>"站点统计", "title_stats_basic"=>"基本概况", "title_stats_forumstat"=>"课程统计", "title_stats_team"=>"管理团队", "title_stats_modworks"=>"管理统计", 
"title_stats_memberlist"=>"会员列表", "title_stats_trend"=>"趋势统计", "title_memcp_pm"=>"发送短消息", "title_memcp_domain"=>"我的空间域名", "title_userapp"=>"应用", "title_userapp_index_all"=>"大家在玩什么", "title_userapp_index_we"=>"好友在玩什么", "title_userapp_index_me"=>"我在玩的", "title_userapp_manage"=>"{userapp}管理", "title_collection"=>"淘帖", "title_collection_create"=>"创建淘专辑", "title_collection_edit"=>"编辑淘专辑", "title_collection_comment_list"=>"评论列表", "title_collection_followers_list"=>"订阅用户列表", "faq"=>"帮助", "search"=>"搜索", "page"=>"第{page}页", "close"=>"关闭"}}, "my_app"=>[], "my_userapp"=>[], "fid"=>0, "tid"=>0, "forum"=>[], "thread"=>[], "rssauth"=>"", 
"home"=>[], "space"=>[], "block"=>[], "article"=>[], "action"=>{"action"=>2, "fid"=>0, "tid"=>0}, "mobile"=>"unknown", "basescript"=>"forum", "basefilename"=>"touch.php", "staticurl"=>"static/", "mod"=>"", "inajax"=>0, "page"=>1, "member_35_status"=>{"uid"=>"35", "regip"=>"106.187.96.204", "lastip"=>"127.0.0.1", "lastvisit"=>"1349512397", "lastactivity"=>"1349512181", "lastpost"=>"1347679420", "lastsendmail"=>"0", "invisible"=>"0", "buyercredit"=>"0", "sellercredit"=>"0", "favtimes"=>"0", "sharetimes"=>"0", "profileprogress"=>"0"}, "tpp"=>20, "ppp"=>10, "currenturl_encode"=>"aHR0cDovL2NudS5rZWppYW4ubHZoLm1lL3NpbXBsZS90b3VjaC5waHA=", "seokeywords"=>"", "seodescription"=>"", "sessoin"=>{"sid"=>"co6B65", "ip1"=>"127", "ip2"=>"0", "ip3"=>"0", "ip4"=>"1", "uid"=>"35", "username"=>"libo-liu", "groupid"=>"1", "invisible"=>"0", "action"=>2, "lastactivity"=>1349512472, "fid"=>0, "tid"=>0, "lastolupdate"=>0}}
    end
    @_G['uid'] = @_G['uid'].to_i
    if !user_signed_in? and @_G['uid'] > 0
      # me off, dz on
      if u = User.authenticate_through_dz_auth!(request,@_G['uid'])
        sign_in(u)
        return true
      end
    elsif user_signed_in? and @_G['uid']==0
      # me on, dz off
      flash[:extra_ucenter_operations] = UCenter::User.synlogin(request,{uid:current_user.uid,psvr_uc_simpleappid:Setting.uc_simpleappid})
    else
      # me off, dz off
      # me on, dz on
      # both nothing to do:)
      return true
    end
  end

  def rand_sid(len)
    @hash = ''
    @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
    @max = @chars.length - 1
    for i in 0...len
      @hash += @chars[Random.rand(@max)]
    end
    return @hash
  end
  
  def create_session_for_dz(sid)
    ip = request.ip.split('.')
    lastactivity = Time.now.to_i
    if !current_user.nil?
      invisible = PreCommonMemberStatus.where(:uid => current_user.uid).first.invisible==0 ? false : true
      user_forsession = PreCommonMember.where(:uid => current_user.uid).first
      username = user_forsession.username
      groupid = user_forsession.groupid
      non_exist_user = PreCommonSession.where(:username => username).first.nil? ? true : false
      if non_exist_user
        uid = current_user.uid
        PreCommonSession.create(uid:uid,sid:sid,username:username,lastactivity:lastactivity,ip1:ip[0],ip2:ip[1],ip3:ip[2],ip4:ip[3],action:2,groupid:groupid)
      end
    else
      uid = 0
      username = ''
      PreCommonSession.create(uid:uid,sid:sid,username:username,lastactivity:lastactivity,ip1:ip[0],ip2:ip[1],ip3:ip[2],ip4:ip[3],action:2,groupid:7)
    end
  end

  def dz_security
    @authkey = UCenter::Php.md5("#{Setting.dz_authkey}#{cookies[Discuz.cookiepre_real+'saltkey']}")
    if user_signed_in?
      @formhash = Discuz::Utils.formhash({'username'=>current_user.slug,'uid'=>current_user.uid,'authkey'=>@authkey})
    else
      @formhash = Discuz::Utils.formhash({'username'=>'','uid'=>0,'authkey'=>@authkey})
    end
  end
  
  before_filter :get_extcredits
  #before_filter :get_srchhotkeywords
  def get_srchhotkeywords
    @s_keyword  = PreCommonSetting.where(:skey => 'srchhotkeywords').first.svalue
    @hotkeywords_list = @s_keyword.split.compact
  end
  def get_extcredits
    if !current_user.nil?
      @cur_newprompt_llb = PreCommonMember.where(:uid => current_user.uid).first.newprompt
      @cur_newpm_llb = UcNewpm.where(:uid => current_user.uid).count
      
      @c_setting  = PreCommonSetting.where(:skey => 'extcredits').first.svalue
      php = PHP.unserialize(@c_setting)
      @extcredit_name = []
      @extcredit_name_list = ''
      php.values.each do |p|
        obj = p['title']
        if !obj.blank?
          @extcredit_name << obj
        end
      end
      @extcredit_name.each_with_index do |ext,index|#1|威望|,2|金钱|,3|贡献|
        @extcredit_name_list += (index+1).to_s + '|' + ext + '|,'
      end
      @extcredit_name_list = @extcredit_name_list.chop  
    end
  end
   
  before_filter :check_privilige
  def check_privilige
    if false and !current_user.nil? and current_user.uid.present?
      @cur_user = PreCommonMember.where(:uid => current_user.uid).first
      @cur_groupid = @cur_user.groupid
      @cur_adminid = @cur_user.adminid
      @cur_newprompt = @cur_user.newprompt
      @cur_allowadmincp = @cur_user.allowadmincp 
      @cur_credits = @cur_user.credits
      @cur_newpm = @cur_user.newpm
      @cur_group = PreCommonUsergroup.where(:groupid => @cur_groupid).first
      @cur_radminid = @cur_group.radminid
     
      @cur_grouptitle = @cur_group.grouptitle
      
      if @cur_radminid > 1
        @fid = PreForumModerator.where(:uid => current_user.uid).first
      end
      #@cur_allowmanage need judge nil?
      @cur_allowmanage = PreCommonBlockPermission.where(:uid => current_user.uid).first 
      if !@cur_adminid.nil?
        @cur_admingroup = PreCommonAdmingroup.where(:admingid => @cur_adminid).first
        if !@cur_admingroup.nil?
          @cur_allowdiy = @cur_admingroup.allowdiy
          @cur_allowmanagearticle = @cur_admingroup.allowmanagearticle
      end
      end
      if !@cur_groupid.nil?
        @cur_allowpostarticle = PreCommonUsergroupField.where(:groupid => @cur_groupid).first
      end
    end
  end
  #==
  def suggest
    if current_user and !(current_user.followed_topic_ids.blank? and current_user.following_ids.blank?)
      elim = current_user.is_expert ? 3 : 2
      ulim = current_user.is_expert ? 0 : 1
      tlim = 2
      e,u,t = UserSuggestItem.find_by_user(current_user)
      @suggested_experts = e.blank? ? [] :  User.any_in(:_id=>e.random(elim)).not_in(:_id=>current_user.following_ids)
      @suggested_users = u.blank? ?  [] :  User.any_in(:_id=>u.random(ulim)).not_in(:_id=>current_user.following_ids)
      @suggested_topics = t.blank? ? [] : Topic.any_in(:name=>t.random(tlim))
    end
  end
  def set_seo_meta(title, options = {})
    keywords = options[:keywords] || "#{Setting.ktv_subname},#{Setting.ktv_sub},课件,讲义,作业,习题解答,往年试卷,课堂录像,复习资料,课件交流系统"
    description = options[:description] || "#{Setting.ktv_subname}课件交流系统"
    if !title.nil? && title.length > 0
      @seo[:title] = "#{title}"
    end
    @seo[:keywords] = keywords
    @seo[:description] = description
  end

  def pagination_get_ready
    params[:page] ||= '1'
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
  end
  def pagination_over(sumcount)
    @page_count = (sumcount*1.0 / @per_page).ceil
  end
  
  
  def user_logged_in_required
    @seo[:title] = '请获取邀请以注册'
    @application_ie_user_logged_in_required = true
    render 'user_logged_in_required',:layout => 'application_ie'
  end
  def modern_required
    @seo[:title] = '请使用更高版本的浏览器'
    render 'modern_required',:layout => 'application_ie'
  end
  def after_sign_in_path_for(resource_or_scope)
    if params[:redirect_to].blank?
      super(resource_or_scope)
    else
      params[:redirect_to]
    end
  end
  def sign_in_others
    # todo:
    #   upon observing this
    #   the sub-site should login the corresponding user
  end
  def sign_out_others
    # todo:
    #   upon observing this
    #   the sub-site should self-destruct its cookies
    #cookies.each do |k,v|
    #  if k.starts_with?(Discuz.cookiepre)
    #    cookies.delete(k, 'domain' => (Discuz.cookiedomain))
    #  end
    #end
  end
  
  
  def suggest
    if current_user and !(current_user.followed_topic_ids.blank? and current_user.following_ids.blank?)
      elim = current_user.is_expert ? 3 : 2
      ulim = current_user.is_expert ? 0 : 1
      tlim = 2
      e,u,t = UserSuggestItem.find_by_user(current_user)
      @suggested_experts = e.blank? ? [] :  User.any_in(:_id=>e.random(elim)).not_in(:_id=>current_user.following_ids)
      @suggested_users = u.blank? ?  [] :  User.any_in(:_id=>u.random(ulim)).not_in(:_id=>current_user.following_ids)
      @suggested_topics = t.blank? ? [] : Topic.any_in(:name=>t.random(tlim))
    end
  end
  
  def bson_invalid_object_id(e)
    raise 'todo'
    # redirect_to root_path, alert: "Resource not found."
  end

  def json_parse_error(e)
    raise 'todo'
    # redirect_to root_path, alert: "Json not valid"
  end

  def mongoid_errors_invalid_type(e)
    raise 'todo'
    # redirect_to root_path, alert: "Json values is not an array"
  end



  def render_optional_error_file(status_code)
    @render_no_sidebar = true
    status = status_code.to_s
    @raw_raw_raw = true
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status}.html.erb", :status => status, :layout => "application"
    else
      render :template => "/errors/unknown.html.erb", :status => status, :layout => "application"
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  before_filter :unknown_user_check
  def unknown_user_check
    if current_user
      unknowns = []
      unknowns << '真实姓名' if current_user.name_unknown
      unknowns << '邮箱地址' if current_user.email_unknown
      #unknowns << '密码' if current_user.encrypted_password.blank?
      unless unknowns.blank?
        flash[:insuf_info] = "请<a href=\"#{edit_user_registration_path}\">点击这里</a>补充您的#{unknowns.join '和'}".html_safe 
      else
        flash[:insuf_info] = nil
      end
    end
  end

  
  def require_admin
    if current_user.blank?
      #@simple_cpanel_layout=true
      #render "cpanel/users/login"
      render file:"#{Rails.root}/public/999.html",layout:false
      return
    end
    if ![User::SUP_ADMIN,User::SUB_ADMIN].include?current_user.admin_type
      #@simple_cpanel_layout=true
      #render "cpanel/users/login"
      render file:"#{Rails.root}/public/999.html",layout:false
      return
    end
  end
  
  def require_user(options = {})
    return true if user_signed_in?
    format = options[:format] || :html
    format = format.to_s
    if params[:redirect_path] and params[:redirect_path]!=''
      redirect_path = params[:redirect_path]
    else
      redirect_path = request.path
    end
    login_url = "/login?redirect_to=#{redirect_path}"
    if format == "html"
      redirect_to login_url
      return false
    elsif format == "json"
      if current_user.blank?
        render :json => { :success => false, :msg => "你还没有登录。" }
        return false
      end
    elsif format == "text"
      # Ajax 调用的时候如果没有登录，那直接返回 nologin，前段自动处理
      if current_user.blank?
        render :text => "_nologin_" 
        return false
      end
    elsif format == "js"
      if current_user.blank?
        render :js => "window.location.href = '#{login_url}';"
        return false
      end
    end
    true
  end

  def require_user_json
    require_user(:format => :json)
  end

  def require_user_js
    require_user(:format => :js)
  end

  def require_user_text
    require_user(:format => :text)
  end
  
  def tag_options(options, escape = true)
    unless options.blank?
      attrs = []
      options.each_pair do |key, value|
        if BOOLEAN_ATTRIBUTES.include?(key)
          attrs << %(#{key}="#{key}") if value
        elsif !value.nil?
          final_value = value.is_a?(Array) ? value.join(" ") : value
          final_value = html_escape(final_value) if escape
          attrs << %(#{key}="#{final_value}")
        end
      end
      " #{attrs.sort * ' '}".html_safe unless attrs.empty?
    end
  end
  
  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
  end
  
  def simple_format(text, html_options={}, options={})
    text = ''.html_safe if text.nil?
    start_tag = tag('p', html_options, true)
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "</p><br />#{start_tag}")  # 2+ newline  -> paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.insert 0, start_tag
    text.html_safe.safe_concat("</p>")
  end
  def common_op!
    params[:page] ||= '1'
    params[:per_page] ||= cookies[:welcome_per_page]
    params[:per_page] ||= '15'
    @page = params[:page].to_i
    @per_page = params[:per_page].to_i
    cookies[:welcome_per_page] = @per_page

    @stat = PreCommonStat.order
    ###session
    @showoldetails = params[:showoldetails]=='no' ? false : true

    ###online list begin
    @session_all = PreCommonSession.all(:limit => 500)
    @online_pic = PreForumOnlinelist.all

    @pic_list = @online_pic.map {|p| p.url}
    @pic_groupid = @online_pic.map {|p| p.groupid}
    @pic_order = @online_pic.map {|p| p.displayorder}
    @pic_title = @online_pic.map {|p| p.title}
    @pic = Hash[@pic_groupid.zip(@pic_order.zip(@pic_title.zip(@pic_list)))]
    @pic_sorted = Hash[@pic.sort_by {|key,value| value[0]}]
    ##@pic => {1       => [1, ["管理员", "online_admin.gif"]],...}
    ##@pic => {groupid  => [display_order,[title,icon]]}
    @onlinelist_uid = @session_all.map {|u| u.uid}
    @onlinelist_username=  @session_all.map {|u| u.username}
    @online_lastactivitytime  =  @session_all.map {|u| u.lastactivity}
    @online_invisible  = @session_all.map {|u| u.invisible}
    @online_groupid = @session_all.map {|u| u.groupid}
    @online_display = Hash[@onlinelist_uid.zip(@onlinelist_username.zip(@online_groupid).zip(@online_lastactivitytime.zip(@online_invisible)))]
    ##online_display => {1=>[["libo-liu", 35], [1346906335, false]],10=>[["gslipt", 62], [1346906466, false]]}
    ##online_display => { uid => [[username,group_id],[lastact,invisible]]}

    @session_count = @session_all.count
    @onlinelist =  @onlinelist_username.compact
    @online_invisible_count = @online_invisible.delete_if {|d| d==false}.count
    @onlinelist_count =  @onlinelist_username.delete_if {|d| d==''}.count

    @guest_count = @session_count - @onlinelist_count

    @online_display.each do |on_keys,on_values|
      if on_values[0][0].blank?
        @online_display.delete(on_keys)
      end
    end
    
    @lastone2display = @pic.values.max[0]
    @on_display = Hash.new
    @pic.each do |keys,values|
      @online_display.each do |on_keys,on_values|
        if @pic.keys.include?(on_values[0][1]) 
          if on_values[0][1] == keys
            @on_display[on_keys] = [values[0]] + on_values +[values[1]]
          end
        else
          @on_display[on_keys] = [@lastone2display] + on_values + [values[1]]
        end
      end
    end
    
    @on_display = Hash[@on_display.sort_by {|key,value| value[0]}]
    ##@on_display => {1=>[["libo-liu", 35], [1346730846, false], ["管理员", "online_admin.gif"]], 3=>[["llb0536", 61], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@on_display => {35=>[1,["libo-liu", 35], [1346730846, false], ["管理员", "online_admin.gif"]], 61=>[3,["llb0536", 61], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@on_display => {35=>[1, ["libo-liu", 1], [1346908864, false], ["管理员", "online_admin.gif"]],, 61=>[3,["llb0536", 4], [1346730774, false], ["版主", "online_moderator.gif"]]}
    ##@onlinelist => {uid => [display_order,[username,group_id],[time,invisible?],[group_title,group_icon]]}
    ###onlinelist end
    
    ###onlinerecord max begin
    @onlinerecord = PreCommonSetting. where(:skey => 'onlinerecord').first.svalue.split.compact
    ###onlinerecord max end
    @coursewares1 = PreForumThread.nondeleted.where('dateline>=?',Date.today.at_beginning_of_day.to_i).order('views desc')
    @cwyesterday = PreForumThread.nondeleted.where('dateline>=? and dateline <?',Date.yesterday.at_beginning_of_day.to_i,Date.today.at_beginning_of_day.to_i).count
    @cw = PreForumThread.nondeleted.count
    @users = PreCommonMember.count
    @newuser =  PreCommonMember.order('regdate').last
  end

end

