# -*- encoding : utf-8 -*-
module Ktv
  class Dangdang
    extend Helpers::Config
    include Helpers::Config
    include Shared::MechanizeParty
    SRC_CHARSET = 'utf-8'
    LOGIN_URI = 'https://login.dangdang.com/Signin.aspx?ReturnUrl='
    GOODS_DESTINY = "http://customer.dangdang.com/myproduct/boughtlist.php?guan_type=01&is_buy="
    PRODUCT_SHOW = "http://product.dangdang.com/product.aspx"
    def self.id2isbn(dangdang_id)
      raise 'todo'
      # response = JQuery.ajax(:type => 'GET',
      #                       :url=>PRODUCT_SHOW,
      #                       :data=>{:product_id=>dangdang_id})
    end
    # 是不是合法的当当网用户名？
    def username_okay?(username)
      get_login_page
      jsonp = "jsonp#{(10.seconds.ago.to_f*1000).to_i}"
      url = "https://login.dangdang.com/p/emailandmobile_check.aspx?usermobile=#{username}&t=#{(Time.now.to_f*1000).to_i}&jsoncallback=#{jsonp}"
      logger.debug url
      result_page = @agent.get(url)
      body = result_page.body.strip.chomp(';')
      if body =~ /^#{jsonp}\((.*)\)$/
        result_json = Utils.safely{JSON.parse($1)}
        return (result_json.nil? ? true : "0"==Utils.safely{result_json["returnval"].strip})
      else
        return true
      end
    end
    def login_path(returnurl=nil)
      ret = 'https://login.dangdang.com/signin.aspx'
      ret += "?returnurl=#{CGI::escape(returnurl)}" if returnurl.present?
      return ret
    end

    def login!(username,password)
      get_login_page(GOODS_DESTINY)
      login_form = @login_page.forms.first
      login_form.txtUsername = username
      login_form.txtPassword = password
      login_result = @agent.submit(login_form,login_form.buttons_with(:id=>'btnSign').first)
      script = login_result.parser.css('script').text
      if script =~ /errorcode\s*=\s*(.+)$/
        errorcode = $1.strip.chomp(';')
        case errorcode
        when "2"
          raise UserDataException,"用户名或密码输入错误，请重新填写"
        when "3","4","6","9","11"
          raise ScriptNeedImprovement,"验证码输入错误，请重新填写"
        when "5"
          raise UserDataException,"该用户名不存在"
        when "7"
          raise UserDataException,"请输入您的登录密码"
        when "8"
          raise UserDataException,"请输入邮箱/昵称/手机号码"
        when "12"
          raise UserDataException,"用户尚未验证，请验证后登录"
        else
          raise ScriptNeedImprovement
        end
      elsif script.include?(GOODS_DESTINY)
        return true
      else
        raise ScriptNeedImprovement
      end
    end

    def get_bought_books(opts={})
      url = "#{GOODS_DESTINY}&pc=#{config.per_page}"
      logger.debug url
      page = @agent.get(url)
      parser = Utils.get_parser(page)
      account_info = parser.css('#__product_type').text()
      logger.info account_info
      #alleged_count = 0
      #if account_info =~ /图书\s*[(（](\d+)[)）]\s*/
      #  alleged_count = $1.to_i
      #end
      pages_count = parser.css('.page_more .num,.page_more .num_now').count
      ret = []
      1.upto(pages_count) do |pageno|
        unless 1==pageno
          page = @agent.get(url+"&page=#{pageno}")
          parser = Utils.get_parser(page)
        end
        parser.css('.mydd_bought').each do |div|
          ret << OpenStruct.new.tap do |book|
            book.dangdang_product_id = div.css('.goods_img a').first.attributes['href'].to_s.split("product_id=").last
            book.created_at = Time.parse div.css('.goods_time').text()
            book.dangdang_order_id = div.css('a[name=orderid]').first.attributes["href"].to_s.split("orderid=").last
            book.title = div.css('.goods_title a[name=product]').first.attributes['title'].to_s
          end
          if opts[:since] and ret.last.created_at <= opts[:since]
            ret.pop
            return ret
          end
        end
      end
      logger.debug ret
      return ret
    end

    protected
    def get_login_page(returnUrl='')
      url = LOGIN_URI+CGI::escape(returnUrl)
      logger.debug url
      @login_page = @agent.get(url)
    end
  end  
end
