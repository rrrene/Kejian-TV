# -*- encoding : utf-8 -*-
module Ktv
  class Chaoxing
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    def self.chaoxing_action!(arr,pre_pattern,u,c,series)
      arr.each do |chaoxing_url|
        next if chaoxing_url.blank?
        if chaoxing_url=~/\_(\d+)\.shtml/
          begin
            flv_url = "#{pre_pattern}#{$1}.flv"
            info = ChaoxingInfo.find_or_create_by(chaoxing_url:chaoxing_url)
            info.flv_url=flv_url
            cw=c.coursewares.build(user_id:u.id,courseware_series_id:series.id,title:$1,sort1:'video',sort2:'xunlei',xunlei_url:flv_url)
            cw.save!
            info.courseware_id=cw.id
            info.save!
          rescue => e
            p e
            binding.pry
          end
        else
          binding.pry
        end
      end
    end
    def self.in_out(pattern)
      Dir[pattern].each_with_index do |filepath,index|
        File.open(filepath) do |f|
          File.open(File.dirname(f)+'/'+index.to_s+".txt","w") do |fout|
            pre_pattern = f.gets
            pre_pattern = pre_pattern.split('/')[0..-2].join('/')+'/'
            while chaoxing_url=f.gets
              next if chaoxing_url.blank?
              if chaoxing_url=~/\_(\d+)\.shtml/
                fout.puts "#{pre_pattern}#{$1}.flv"
              end
            end
          end
        end
      end
    end
  end
end
