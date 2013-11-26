# -*- encoding : utf-8 -*-
module Ktv
  class Kejian1
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    CATEGORIES = [:computer,:foreign,:elementary,:junior,:senior,:university,:graduate,:zige,:jineng]
    def crawl_video_sets_all
      $psvr_crawl_got_it = false
      $psvr_crawl_dest='http://video.1kejian.com/computer/pcother/23619/'
      CATEGORIES.each{|cat| crawl_video_sets(cat)}
    end
    def crawl_video_sets(category)
      kejian1 = {}
      kejian1[:category] = category
      puts url = "http://video.1kejian.com/#{category}/index.html"
      raise ScriptNeedImprovement unless url.present?
      page = @agent.get(url)
      numbers = []
      page_cnt = 0
      parser = page.parser
      parser.css('#pages a').each do |link|
        if link.attributes['href'].value =~ /\/index(\d+)\.html/
          numbers << $1.to_i
        end
        page_cnt = numbers.max
      end
      site.att["#{category}_page_cnt"] = page_cnt
      crawl_video_sets_inside(page.parser)
      2.upto(page_cnt) do |page_no|
        begin
          puts url = "http://video.1kejian.com/#{category}/index#{page_no}.html"
          raise ScriptNeedImprovement unless url.present?
          page = @agent.get(url)
          crawl_video_sets_inside(page.parser)
        rescue => e
          puts "#{e}"
          site.err_msgs << "#{e}"
        end
      end
      site.save!
    end
    def crawl_video_sets_inside(parser)
      parser.css('.movList li.hb').each do |li|
        puts url = "http://video.1kejian.com#{li.css('p a').attribute('href').value}"
        raise ScriptNeedImprovement unless url.present?
        $psvr_crawl_got_it = true if $psvr_crawl_dest==url 
        next unless $psvr_crawl_got_it
        video_set = VideoSet.find_or_create_by(url:url)
        video_set.title = li.css('p a').attribute('title').value
        video_set.kejian1['cover_src'] = li.css('a img').attribute('src').value

        page = @agent.get(video_set.url)
        parser = page.parser
        inner_html = parser.css('.brief_info_cont').first.inner_html
        video_set.desc = Utils.safely(inner_html){inner_html.encode('utf-8')}
        links = parser.css('ul.split-list a')
        video_set.videos_count = links.count
        0.upto(video_set.videos_count-1) do |i|
          link = links[i]
          puts url = "http://video.1kejian.com#{link.attribute('href').value}"
          raise ScriptNeedImprovement unless url.present?
          video = video_set.videos.find_or_create_by(url:url)
          video.title = link.attribute('title').value
          video.save!
        end
        link = links.first
        puts url = "http://video.1kejian.com#{link.attribute('href').value}"
        raise ScriptNeedImprovement unless url.present?
        page = @agent.get(url)
        parser = page.parser
        video_set.kejian1['VideoListJson'] = parser.css('div.center script').text
        video_set.save!
      end
    end
  end
end

