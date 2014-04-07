class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

    def wl_DetectUserAgent
      # 做这个首页需要考虑用户来自" ipad"," gt p6200 "," xoom "," tablet "这类平板还是" android"," windows phone" ," ios"," iphone"," ipod"这类手机还是"msie","ie","chrome", "safari","firefox","opera"这类普通电脑浏览器
      # 每种平台的展示效果都不一样，要分三类单独处理
      # 给移动设备做一个，给浏览器做一个，给低端浏览器（包括小于9.0的ie和小于12.0的火狐以及平板上的浏览器）做一个
      userAgent = request.env['HTTP_USER_AGENT'].to_s.downcase
      clean = userAgent.gsub(/[^a-z 0-9 .]+/, ' ')
      clean = clean.split(" ")
      cleanLength = clean.length
      clean.delete_if{|x| x == ""}
      clean = clean.join(',')
      clean.gsub!(/,/, ' ')
      clean = " "+clean+" "
      
      tablets = [" ipad"," gt p6200 "," xoom "," tablet "]
      tabletsLength = tablets.length
      tablets.each{|tablet|
        if clean.include?(tablet)
          return "basic"
        end
      }
  
      mobiles = [" android"," windows phone" ," ios"," iphone"," ipod"];
      mobilesLength = mobiles.length;
      mos=''
      version=-1
      mobiles.each{|mobile|
        index = clean.index(mobile)
        next if index.nil?
        p = clean[(index+1+mobile.length)...(clean.length)].split(" ", 1)[0..0]
        version = p[0].to_f
        version = -1 if version.nan? || version==0.0
        mos = mobile
        break
      }
  
      if mos == " windows phone"
        return "mobile";
      elsif mos == " ios"
        return "mobile";
      elsif mos == " iphone" || mos == " ipod"
        return "mobile";
      elsif mos == " android"
        if version > 0
          if version < 3.0
            return "mobile"
          end
          if version >= 4.0
            return "basic"
          end
          if version == 3.2
            return "basic"
          end
        else
          return "mobile"
        end
      else
      end
  
      browsers = ["msie","ie","chrome", "safari","firefox","opera"]
      browser=''
      version=-1
      browsers.each do |b|
        index = clean.index(" "+b+" ")
        next if index.nil?
        p = clean[(index+1+b.length+1)...(clean.length)].split(" ", 1)[0..0]
        version = p[0].to_f
        version = -1 if version.nan? || version==0.0
        browser = b
        break
      end
  
  
      if browser == "msie"# && version < 10.0 && version != -1
        return "basic"
      elsif browser == "ie"# && version < 10.0 && version != -1
        return "basic"
      elsif browser == "firefox" && version <12.0 && version != -1
        return "basic"
      else
        return ""
      end
    end

end
