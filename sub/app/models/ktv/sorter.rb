# -*- encoding : utf-8 -*-
require 'open-uri' 
module Ktv
  class Sorter
      
      def self.sort_by_playlist
        pl = PlayList.all
        pl.each do |p|
        #    sortstr = self.sort(p.title)
           p.content.each  do |cwid|
                cw = Courseware.find(cwid)
                cw.update_attribute(:sort1,sortstr)
            end
        end
      end
      
      def self.sort(title)
        url =URI.parse(URI.encode(("http://localhost:9200/global/_analyze?text=" + title).strip))
        response = open(url).read

        hash = MultiJson.decode(response)
        tokens = hash['tokens'].map {|x| x['token']}
        
      end
      def self.courseArtifical
        cws = Courseware.where(:sort1=>nil)
        cws.each_with_index do |cw,index|
          if !cw.sort1.nil?
            next
          end
          ar = Airule.new
          ar.cw_id = cw.id
          ar.file_type = cw.sort
          puts index.to_s + '-' + Courseware.where(:sort1=>nil).count.to_s + '、[' + cw.id.to_s + ']  '+ cw.title
          aa = Hash[Airule.where(:user_name=>cw.ibeike_uname).map{|x| x.sortstr}.group_by(&:capitalize).map {|k,v| [k, v.length]}].max_by{|k,v| v}
          aa = aa[0] if !aa.nil?
          aa = 'none' if aa.nil?
          puts 'User:' + cw.ibeike_uname + '     推荐：' + aa
          puts ibeike_name = OcwCourses.find(cw.ibeike_id).title 
          cname = nil
          type = Readline.readline('>> ', true)
  	      case type.downcase
           when 'l'
             sortstr = 'lecture_notes'
           when 'a'
             sortstr = 'assignments'                                                                     
           when 'e'
             sortstr = 'exams'                                                                           
           when 'm'
             sortstr = 'materials'                                                                       
           else
             sortstr = 'lecture_notes'
           end
           puts '归属为' + Courseware::SORT1STR[sortstr]
           puts '名字处理：a合并名字(title在后)，b合并名字(title在前)，r替换名字，pp手动输入名字，默认保持不变'
           name = Readline.readline('>> ', true)
           ar.sortstr = sortstr
           case name.downcase
             when 'a','b' 
               ar.rules = ar.rules << cw.title
               ar.rules = ar.rules << ibeike_name
             when 'r'
               ar.rules = ar.rules << ibeike_name
             when 'pp'
               cname = Readline.readline('>> ',true)
               ar.rules = ar.rules << cname
             else
               ar.rules = ar.rules << cw.title
           end
           ar.choices = ar.choices << cw.title
           ar.choices = ar.choices << ibeike_name
           ar.choices = ar.choices << cname if !cname.nil?
           puts 'Are you sure?'
           yn = Readline.readline('>> ', true)
           if yn.downcase == 'n'
             ar.accepted = false
             ar.save(:validate=>false)
             next
           end
         
           case name.downcase
           when 'a'
             cw.update_attribute(:title,ibeike_name+' ' + cw.title)
           when 'r'
             cw.update_attribute(:title,ibeike_name)
           when 'b'
             cw.update_attribute(:title,cw.title+' ' + ibeike_name)
           when 'pp'
             cw.update_attribute(:title,cname)
           else
             #do nothing
           end
           puts 'Title:'+cw.title
           puts ' '
           cw.update_attribute(:sort1,sortstr) 
           ar.accepted = true
           ar.save(:validate=>false)
           puts 'Done'
           puts ' '
           

        end
      end
      def self.artifical
        pl = PlayList.all
        pl.each_with_index do |p,index|
           if !p.sort1.nil?
             next
           end
           puts index.to_s + '['+p.id.to_s+']'+p.title
           pp p.content.map{|x| Courseware.find(x).title}
           puts '属于类型:'
           type = Readline.readline('>> ', true)
           case type
           when 'l'
             sortstr = 'lecture_notes'
           when 'a'
             sortstr = 'assignments'
           when 'e'
             sortstr = 'exams'
           when 'm'
             sortstr = 'materials'
           else
             sortstr = 'lecture_notes'
           end
           puts '归属为' + Courseware::SORT1STR[sortstr]
           puts ''
           puts '' 
           p.update_attribute(:sort1,sortstr)
           p.content.each  do |cwid|
                cw = Courseware.find(cwid)
                cw.update_attribute(:sort1,sortstr)
            end
        end
      end
      KEYWORD = {
        '试卷'=>'exams',
        '答案,卷'=>'exams',
        '书' =>'materials',
        '课,件,答案'=>'assignments',
        '考试'=>'exams',
        '作业'=>'assignments',
        '课,后,答案'=>'assignments' 
      }
  end
end
