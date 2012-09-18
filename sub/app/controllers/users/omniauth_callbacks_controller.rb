# -*- encoding : utf-8 -*-
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :prepare_auth
# todo: combine user when email clashes
  def weibo
    @user.name = @info['name']
    @user.nickname = @info['nickname']
    @user.location = @info['location']
    @user.bio = @info['description']
    if @info['urls'].present?
      @user.website = @info['urls']['Website']
      @user.weibo = @info['urls']['Weibo']
    end

    @backinfo = {:weibo => Hash[
      "info" => env["omniauth.auth"]['info'],
      "raw_info" => env["omniauth.auth"]['extra']['raw_info']
    ]}
    make_it_done!
=begin
http://api.t.sina.com.cn/oauth/authorize?oauth_callback=http%3A%2F%2F0.0.0.0%3A3000%2Faccount%2Fauth%2Fweibo%2Fcallback&oauth_token=ed7d6c0c8a59519cebc380509b1fb8ee
  |
  |
 \ /
http://0.0.0.0:3000/account/auth/weibo/callback?oauth_token=6856d78727e5eb5cd28b900473822f29&oauth_verifier=483778

"omniauth.origin"=>"http://0.0.0.0:3000/",
"omniauth.auth" => {"provider"=>"weibo",
   "uid"=>1947145061,
   "info"=>
    {"nickname"=>"劈哀思唯啊",
     "name"=>"劈哀思唯啊",
     "location"=>"北京",
     "image"=>"http://tp2.sinaimg.cn/1947145061/50/5628658224/1",
     "description"=>"",
     "urls"=>{"Website"=>"", "Weibo"=>"http://weibo.com/1947145061"}},
   "credentials"=>
    {"token"=>"099b1fee964d6bf1a3cf573ee187d04c",
     "secret"=>"c964cec77754617c2c49c088f420582b"},
   "extra"=>
    {"access_token"=>
      #<OAuth::AccessToken:0x007fc0a3246790
       @consumer=
        #<OAuth::Consumer:0x007fc0a3388a18
         @http=#<Net::HTTP api.t.sina.com.cn:80 open=false>,
         @http_method=:post,
         @key="2867528422",
         @options=
          {:signature_method=>"HMAC-SHA1",
           :request_token_path=>"/oauth/request_token",
           :authorize_path=>"/oauth/authorize",
           :access_token_path=>"/oauth/access_token",
           :proxy=>nil,
           :scheme=>:header,
           :http_method=>:post,
           :oauth_version=>"1.0",
           :realm=>"OmniAuth",
           :site=>"http://api.t.sina.com.cn"},
         @secret="7125b8f33ce1e530ed4f43ed9fcd6232",
         @uri=#<URI::HTTP:0x007fc0a32502e0 URL:http://api.t.sina.com.cn>>,
       @params=
        {:oauth_token=>"099b1fee964d6bf1a3cf573ee187d04c",
         "oauth_token"=>"099b1fee964d6bf1a3cf573ee187d04c",
         :oauth_token_secret=>"c964cec77754617c2c49c088f420582b",
         "oauth_token_secret"=>"c964cec77754617c2c49c088f420582b",
         :user_id=>"1947145061",
         "user_id"=>"1947145061"},
       @response=#<Net::HTTPOK 200 OK readbody=true>,
       @secret="c964cec77754617c2c49c088f420582b",
       @token="099b1fee964d6bf1a3cf573ee187d04c">,
     "raw_info"=>
      {"id"=>1947145061,
       "screen_name"=>"劈哀思唯啊",
       "name"=>"劈哀思唯啊",
       "province"=>"11",
       "city"=>"1000",
       "location"=>"北京",
       "description"=>"",
       "url"=>"",
       "profile_image_url"=>"http://tp2.sinaimg.cn/1947145061/50/5628658224/1",
       "domain"=>"",
       "gender"=>"m",
       "followers_count"=>10,
       "friends_count"=>51,
       "statuses_count"=>67,
       "favourites_count"=>0,
       "created_at"=>"Fri Mar 25 00:00:00 +0800 2011",
       "following"=>false,
       "allow_all_act_msg"=>false,
       "geo_enabled"=>true,
       "verified"=>false,
       "status"=>
        {"created_at"=>"Wed May 30 22:40:48 +0800 2012",
         "id"=>3451515349633960,
         "text"=>
          "May 18, 2012 - 夜幕降临前，Facebook位于俄勒冈州的Prineville新数据中心，美国。Facebook刚刚宣布首次公开募股(IPO)价格周四定为每
         "source"=>
          "<a href=\"http://idai.ly\" rel=\"nofollow\">iDaily每日环球视野</a>",
         "favorited"=>false,
         "truncated"=>false,
         "in_reply_to_status_id"=>"",
         "in_reply_to_user_id"=>"",
         "in_reply_to_screen_name"=>"",
         "thumbnail_pic"=>
          "http://ww3.sinaimg.cn/thumbnail/740f1365jw1dtgq69aswij.jpg",
         "bmiddle_pic"=>
          "http://ww3.sinaimg.cn/bmiddle/740f1365jw1dtgq69aswij.jpg",
         "original_pic"=>
          "http://ww3.sinaimg.cn/large/740f1365jw1dtgq69aswij.jpg",
         "geo"=>nil,
         "mid"=>"3451515349633960"}}}}
=end
  end
  
  def renren
    @user.name = @info['name']
    if @info['urls'].present?
      @user.renren = @info['urls']['Renren']
    end
    @backinfo = {:renren => Hash[
      "info" => env["omniauth.auth"]['info'],
      "raw_info" => env["omniauth.auth"]['extra']['raw_info']
    ]}
    make_it_done!
=begin
http://graph.renren.com/login?redirect_uri=http%3A%2F%2Fgraph.renren.com%2Foauth%2Fauthorize%3Fclient_id%3D7cd5a7b942f04e4086993865532d47e2%26redirect_uri%3Dhttp%253A%252F%252Fkejian.tv%252Faccount%252Fauth%252Frenren%252Fcallback%26response_type%3Dcode%26display%3Dpage%26scope%3Dpublish_feed%26pp%3D1%26origin%3D00000&origin=80000
 |
 |
\ /
http://kejian.tv/account/auth/renren/callback?code=WfL07b6LEb10in0KeNN4V6uVT5ZBpUzh
=> {"provider"=>"renren",
 "uid"=>285692613,
 "info"=>
  {"uid"=>285692613,
   "gender"=>"Male",
   "image"=>"http://head.xiaonei.com/photos/0/0/men_head.gif",
   "name"=>"潘旻琦",
   "urls"=>{"Renren"=>"http://www.renren.com/profile.do?id=285692613"}},
 "credentials"=>
  {"token"=>
    "197144|6.f6853dfee58abe2a38144e49d727844c.2592000.1341115200-285692613",
   "refresh_token"=>"197144|0.D51X9e60X8m1OqqehZ37by3dETpOV23V.285692613",
   "expires_at"=>1341115199,
   "expires"=>true},
 "extra"=>{}}
=end
  end
  
  def douban
    @user.name = @info['name']
    @user.nickname = @info['nickname']
    @user.location = @info['location']
    @user.bio = @info['description']
    if @info['urls'].present?
      @user.douban = @info['urls']['Douban']
    end
    @backinfo = {:douban => Hash[
      "info" => env["omniauth.auth"]['info']
    ]}
    make_it_done!
=begin
http://www.douban.com/service/auth/authorize?oauth_callback=http%3A%2F%2F0.0.0.0%3A3000%2Faccount%2Fauth%2Fdouban%2Fcallback&oauth_token=0b4b0dbf6079065e21e1293e216b131a
 |
 |
\ /
http://0.0.0.0:3000/account/auth/douban/callback?oauth_token=0b4b0dbf6079065e21e1293e216b131a
=> {"provider"=>"douban",
 "uid"=>"2576410",
 "info"=>
  {"nickname"=>"2576410",
   "name"=>"试管牛",
   "location"=>nil,
   "image"=>"http://img3.douban.com/icon/u2576410-8.jpg",
   "description"=>"",
   "urls"=>{"Douban"=>"http://www.douban.com/people/2576410/"}},
 "credentials"=>
  {"token"=>"0be70983341b133223b51c899c513996", "secret"=>"d6d8bce810ab5c11"},
 "extra"=>
  {"access_token"=>
    #<OAuth::AccessToken:0x007fc0a3c30e90
     @consumer=
      #<OAuth::Consumer:0x007fc0a55e2e10
       @http=#<Net::HTTP www.douban.com:80 open=false>,
       @http_method=:post,
       @key="047e55e70a1523d60d7b01b51e3f6b82",
       @options=
        {:signature_method=>"HMAC-SHA1",
         :request_token_path=>"/service/auth/request_token",
         :authorize_path=>"/service/auth/authorize",
         :access_token_path=>"/service/auth/access_token",
         :proxy=>nil,
         :scheme=>:header,
         :http_method=>:post,
         :oauth_version=>"1.0",
         :realm=>"OmniAuth",
         :site=>"http://www.douban.com"},
       @secret="714da547088e67ad",
       @uri=#<URI::HTTP:0x007fc0a52ba300 URL:http://www.douban.com>>,
     @params=
      {:oauth_token_secret=>"d6d8bce810ab5c11",
       "oauth_token_secret"=>"d6d8bce810ab5c11",
       :oauth_token=>"0be70983341b133223b51c899c513996",
       "oauth_token"=>"0be70983341b133223b51c899c513996",
       :douban_user_id=>"2576410",
       "douban_user_id"=>"2576410"},
     @response=#<Net::HTTPOK 200 OK readbody=true>,
     @secret="d6d8bce810ab5c11",
     @token="0be70983341b133223b51c899c513996">,
   "raw_info"=>
    {"db:uid"=>{"$t"=>"2576410"},
     "db:signature"=>{"$t"=>""},
     "db:location"=>{"$t"=>"北京", "@id"=>"beijing"},
     "title"=>{"$t"=>"试管牛"},
     "uri"=>{"$t"=>"http://api.douban.com/people/2576410"},
     "content"=>{"$t"=>""},
     "link"=>
      [{"@rel"=>"self", "@href"=>"http://api.douban.com/people/2576410"},
        {"@rel"=>"alternate", "@href"=>"http://www.douban.com/people/2576410/"},
        {"@rel"=>"icon",
         "@href"=>"http://img3.douban.com/icon/u2576410-8.jpg"}],
      "db:attribute"=>
       [{"$t"=>0, "@name"=>"n_mails"}, {"$t"=>0, "@name"=>"n_notifications"}],
      "id"=>{"$t"=>"http://api.douban.com/people/2576410"}}}}
=end    
  end
  
  def qq_connect
    @user.name = @info['name']
    @user.nickname = @info['nickname']
    @backinfo = {:qq_connect => Hash[
      "info" => env["omniauth.auth"]['info'],
      "raw_info" => env["omniauth.auth"]['extra']['raw_info']
    ]}
    make_it_done!
=begin
http://openapi.qzone.qq.com/oauth/show?which=ConfirmPage&response_type=code&client_id=100276122&redirect_uri=http%3A%2F%2Fkejian.tv%2Faccount%2Fauth%2Fqq_connect%2Fcallback
 |
 |
\ /
http://kejian.tv/account/auth/qq_connect/callback?code=E0D6944EBFE444F7CE00EA8D7B7C42EC
=> {"provider"=>"qq_connect",
 "uid"=>"CD56EC8B441BE5D6C1F2F732318F823C",
 "info"=>
  {"nickname"=>"P.S.V.R",
   "name"=>"P.S.V.R",
   "image"=>
    "http://qzapp.qlogo.cn/qzapp/100276122/CD56EC8B441BE5D6C1F2F732318F823C/50"},
 "credentials"=>
  {"token"=>"67715717B0618BAB5CB42580082332BB",
   "expires_at"=>1346296450,
   "expires"=>true},
 "extra"=>
  {"raw_info"=>
    {"ret"=>0,
     "msg"=>"",
     "nickname"=>"P.S.V.R",
     "figureurl"=>
      "http://qzapp.qlogo.cn/qzapp/100276122/CD56EC8B441BE5D6C1F2F732318F823C/30",
     "figureurl_1"=>
      "http://qzapp.qlogo.cn/qzapp/100276122/CD56EC8B441BE5D6C1F2F732318F823C/50",
     "figureurl_2"=>
      "http://qzapp.qlogo.cn/qzapp/100276122/CD56EC8B441BE5D6C1F2F732318F823C/100",
     "gender"=>"女",
     "vip"=>"0",
     "level"=>"0"}}}
=end
  end
  
  def google_oauth2
    @user.name = @info['name']
    @user.email = @info['email']
    @user.force_confirmation_instructions = true
    @backinfo = {:google_oauth2 => Hash[
      "info" => env["omniauth.auth"]['info'],
      "raw_info" => env["omniauth.auth"]['extra']['raw_info']
    ]}
    make_it_done!
=begin
[1] pry(#<Users::OmniauthCallbacksController>)> 
[2] pry(#<Users::OmniauthCallbacksController>)> env["omniauth.auth"]
=> {"provider"=>"google_oauth2",
 "uid"=>"102384363156908900763",
 "info"=>
  {"name"=>"Minqi Pan",
   "email"=>"pmq2001@gmail.com",
   "first_name"=>"Minqi",
   "last_name"=>"Pan",
   "image"=>
    "https://lh6.googleusercontent.com/-gbIM-7w-RGU/AAAAAAAAAAI/AAAAAAAABsE/U3OYcUtny58/photo.jpg"},
 "credentials"=>
  {"token"=>"ya29.AHES6ZQ5DNBUbgnBbuWLd5CJNGFk3Ww6MI7G91m3Ps-ba9kjCLlZ4g",
   "refresh_token"=>"1/Ges70gS1s25OKNVgC38e0qlONGU-OevBbeHL_nCcb-M",
   "expires_at"=>1341754271,
   "expires"=>true},
 "extra"=>
  {"raw_info"=>
    {"id"=>"102384363156908900763",
     "email"=>"pmq2001@gmail.com",
     "verified_email"=>true,
     "name"=>"Minqi Pan",
     "given_name"=>"Minqi",
     "family_name"=>"Pan",
     "link"=>"https://plus.google.com/102384363156908900763",
     "picture"=>
      "https://lh6.googleusercontent.com/-gbIM-7w-RGU/AAAAAAAAAAI/AAAAAAAABsE/U3OYcUtny58/photo.jpg",
     "gender"=>"male",
     "locale"=>"en"}}}

=end
  end
  
  def github
    @user.name = @info['name']
    @user.nickname = @info['nickname']
    @user.email = @info['email']
    if @info['urls'].present?
      @user.website = @info['urls']['Blog']
      @user.github = @info['urls']['GitHub']
    end
    @user.force_confirmation_instructions = true
    @backinfo = {:github => Hash[
      "info" => env["omniauth.auth"]['info'],
      "raw_info" => env["omniauth.auth"]['extra']['raw_info']
    ]}
    make_it_done!
=begin
=> {"provider"=>"github",
 "uid"=>13315,
 "info"=>
  {"nickname"=>"pmq20",
   "email"=>"pmq2001@gmail.com",
   "name"=>"P.S.V.R",
   "urls"=>
    {"GitHub"=>"https://github.com/pmq20", "Blog"=>"http://ofpsvr.org"}},
 "credentials"=>
  {"token"=>"20442be795269026e3936d7c8dfae09252351434", "expires"=>false},
 "extra"=>
  {"raw_info"=>
    {"followers"=>29,
     "type"=>"User",
     "bio"=>nil,
     "html_url"=>"https://github.com/pmq20",
     "email"=>"pmq2001@gmail.com",
     "public_gists"=>24,
     "created_at"=>"2008-06-11T07:46:37Z",
     "location"=>"Beijing",
     "url"=>"https://api.github.com/users/pmq20",
     "avatar_url"=>
      "https://secure.gravatar.com/avatar/8002c84eb4c18170632f8fb7efb09288?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png",
     "company"=>"",
     "gravatar_id"=>"8002c84eb4c18170632f8fb7efb09288",
     "name"=>"P.S.V.R",
     "following"=>52,
     "blog"=>"http://ofpsvr.org",
     "hireable"=>false,
     "id"=>13315,
     "public_repos"=>73,
     "login"=>"pmq20"}}}
=end
  end
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  
  # This is solution for existing accout want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end
  
private
  def prepare_auth
    redirect_to(root_path,:alert => '认证失败') and return if env["omniauth.auth"].blank?
    provider = env["omniauth.auth"]['provider'].to_s
    uid = env["omniauth.auth"]['uid'].to_s
    @user = User.where("authorizations.provider" => provider , "authorizations.uid" => uid).first
    @user ||= User.new
    @auth = @user.authorizations.find_or_create_by(:provider=> provider,:uid=>uid)
    @info = env["omniauth.auth"]['info']
    p env["omniauth.auth"].inspect
    return true
  end
  def make_it_done!
    unless @user.valid?
      @user.name_unknown = true if @user.errors[:name].present?
      @user.email_unknown = true if @user.errors[:email].present?
      raise @user.errors.full_messages.join(',') unless @user.valid?
    end
    @user.regip = request.ip
    if @user.save
      UserInfo.user_id_find_or_create(@user.id,@backinfo)
      @auth.update_attribute(:user_id, @user.id)
      sign_in(@user)
      if(@user.name_unknown or @user.email_unknown)
        redirect_to(edit_user_registration_path(:force_password_change => 1), :notice => '谢谢！您已经成功登录，请补充您的真实姓名和邮箱地址，并设置新密码。')
      else
        redirect_to(root_path, :notice =>  '谢谢！您已经成功登录。')
      end
    else
      raise @user.errors
    end
    
  end
end

