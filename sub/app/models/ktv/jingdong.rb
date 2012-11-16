# -*- encoding : utf-8 -*-
module Ktv
  class Jingdong
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    LOGIN_URI = 'https://passport.360buy.com/new/login.aspx?ReturnUrl='
    BOOKPRODUCT_PAGE = 'http://book.360buy.com/'
    GOODS_DESTINY = 'http://jd2008.360buy.com/JdHome/OrderList.aspx'
    GOODS_DESTINY2 = 'http://jd2008.360buy.com/JdHome/OrderLists.aspx'
    def id2isbn(id)
      page = agent.get "#{BOOKPRODUCT_PAGE}#{id}.html"
      parser = Utils.get_parser(page)
      summary = parser.css('#summary').text
      if summary =~ /ＩＳＢＮ：(\d{13})/
        return $1
      else
        return ''
      end
    end
    def login!(username,password)
      get_login_page(GOODS_DESTINY)
      form = @login_page.forms.first
      parser = Utils.get_parser(@login_page)
      srcValue = parser.css('#JD_Verification1').attribute('src2').value
      uuid = srcValue.split("&uid=")[1].split("&")[0]
      cxt = V8::Context.new      
      postresult = agent.post(
        "https://passport.360buy.com/new/LoginService.aspx?uuid=" + uuid + "&" + @login_page.uri.to_s.split('?')[-1].to_s + "&r=" + rand.to_s,
        {
          authcode:'',
          chkRememberUsername:'on',
          loginname:username,
          loginpwd:password
        },
        {
          'Pragma' => 'no-cache',
          'Referer' => 'https://passport.360buy.com/new/login.aspx?ReturnUrl=http%3A%2F%2Fwww.360buy.com%2F',
          'X-Requested-With' => 'XMLHttpRequest'
        }
      )
      result = cxt.eval postresult.body
      if result['success'].present?
        return true
      elsif result['transfer'].present?
        raise ScriptNeedImprovement
      elsif result['verifycode'].present?
        raise ScriptNeedImprovement    
      elsif result['username'].present?
        raise UserDataException,result['username']
      elsif result['pwd'].present?
        raise UserDataException,result['pwd']   
      elsif result['authcode'].present?
        raise ScriptNeedImprovement  
      else
        raise ScriptNeedImprovement  
      end
    end
    def get_bought_books(opts={})
      ret = []
      [GOODS_DESTINY2,GOODS_DESTINY].each do |path|
        page = agent.get path
        parser = Utils.get_parser(page)
        parser.css('tr[id^=track]').each do |tr|
          detail = tr.css('td[class=order-doi] a').attribute('href').value
          detail = agent.get detail
          detailp = Utils.get_parser(detail)
          created_at = Time.parse tr.css('span[class=ftx-03]').text
          if detail.uri.to_s =~ /orderid=(\d+)/
            order_id = $1
          else
            order_id = nil
          end
          detailp.css('.p-list tr').each do |item|
            tds = item.css('td')
            next unless 7==tds.count
            ret << OpenStruct.new.tap do |book|
              book.jingdong_product_id = tds[0].text.strip
              book.created_at = created_at
              book.title = tds[1].text.strip
              book.jingdong_order_id = order_id
            end
          end
        end
      end
      logger.debug ret
      return ret
    end
    protected
    def verc
      cxt = V8::Context.new
      src = cxt.eval parser.css('#JD_Verification1').attribute('onclick').value
    end
    def get_login_page(returnUrl='')
      url = LOGIN_URI+CGI::escape(returnUrl)
      logger.debug url
      @login_page = @agent.get(url)
    end
  end  
end
