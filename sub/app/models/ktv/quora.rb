# -*- encoding : utf-8 -*-
module Ktv
  class Quora
    def self.zhankai!(div,index,li)
      old_count = li.all(:xpath,"./ul/li/div/ul").count
      puts old_count;STDOUT.flush
      if old_count>0
        begin
          li.all(:xpath,"./ul/ul/li/a").each do |show_more_anchor|
            show_more_anchor.click
            wait = Selenium::WebDriver::Wait.new(:timeout => 180) # seconds
            wait.until{
              li.all(:xpath,"./ul/li/div/ul").count>old_count
            }
          end
        rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
          p e
          li = div.first(:xpath,'./ul').all(:xpath,"./li")[index]
        end
        puts li.all(:xpath,"./ul/li/div/ul").count;STDOUT.flush
      end
      li
    end
    def self.handle_ul(div,up_name)
      sum = div.first(:xpath,'./ul').all(:xpath,"./li").count
      index = 0
      while index < sum
        li = div.first(:xpath,'./ul').all(:xpath,"./li")[index]
        anchor = li.first(:xpath,'./span/span/a')
        href = anchor.attribute('href')
        father_name = anchor.first(:xpath,'./span/span').text
        father_inst = Topic.locate(father_name)
        father_inst.quora = {href:href}
        father_inst.fathers<<up_name
        puts "[#{father_name},#{up_name}]";STDOUT.flush
        li = zhankai!(div,index,li)
        li.all(:xpath,"./ul/li/div").each do |next_div|
          handle_ul(next_div,father_name)
          begin
            li.first(:xpath,"./ul/ul/li/a")
            puts "哎呀！！！";STDOUT.flush
            li = zhankai!(div,index,li)
          rescue => e
            p e
          end
        end
        father_inst.quora['more'] = true if li.all(:xpath,'./ul/ul/li/small').count>0
        father_inst.save(:validate=>false)
        index += 1
      end
    end
    def self.start!
      http_client = Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = 10000
      driver = Selenium::WebDriver.for(:chrome,:http_client=> http_client)
      driver.navigate.to "http://www.quora.com/"
      element = driver.find_element(:name,'email')
      element.send_keys('pmq2001@gmail.com')
      element = driver.find_element(:name,'password')
      element.send_keys('pmqpmQ55')
      driver.find_element(:css, "input[type=submit]").click
      sleep 3
      driver.navigate.to "http://www.quora.com/Academic-Applied-Disciplines/ontology"
      driver.all(:css, '.e_col .w4_5 .row_border > div > div > ul > li > ul > li > div').each do |root_div|
        self.handle_ul(root_div,'课程根')
      end
    end
  end  
end
