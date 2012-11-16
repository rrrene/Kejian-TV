# -*- encoding : utf-8 -*-
require 'open-uri'
module Ktv
  class Spider
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    def self.testcnu!
      cnu = Ktv::Spider.new
      cnu.start_mode(:cnu,'1090500165','pmqpmq55')
      #cnu.touch_courses_teachings_departments_teachers
      #Course.all.each{|x| x.update_attribute(:years,[20122])}
      cnu.touch_all_courses
    end
    def self.testcnu_yjs!
      cnu = Ktv::Spider.new
      cnu.start_mode(:cnu_yjs,'2100502084','2100502084')
    end
    def self.testustb!
      ustb = Ktv::Spider.new
      ustb.start_mode(:ustb,'','')
      ustb.touch_courses_departments_ustb_college
      ustb.touch_course_department_public_ustb
      Course.all.each{|x| x.update_attribute(:years,[20122])}
      
      Teaching.add_ibeikeTeachers_and_user_add_Courses!
      OcwCourses.import_into_dz!
      # Department.reflect_onto_discuz!
      # Course.reflect_onto_discuz!
    end
    def self.testbuaa!
      buaa = Ktv::Spider.new
      buaa.start_mode(:buaa,'','')
      buaa.touch_course_departments_buaa
      Course.all.each{|x| x.update_attribute(:years,[20122])}
    end
    def self.testruc!(is_all)  #is_all = true will read teacher from 2005 to 2021; is_all = false will read teacher from 2010 to 2021
      ruc = Ktv::Spider.new
      ruc.start_mode(:ruc,'2009201692','zjx1990726')
      ruc.ruc_snatch_all_course_department(is_all)
    end

    def start_mode(mode,username,password)
      @mode = mode
      case @mode
      when :cnu
        @base_url = 'http://202.204.208.75'
        @page = @agent.post("#{@base_url}/loginAction.do",{ldap:'auth',zjh:username,mm:password})
      when :cnu_yjs
        @base_url = 'http://yjsjw.cnu.edu.cn:8082/'
        @page = @agent.get("#{@base_url}/login.do") 
        form = @page.forms[0]
        form['j_username']=username
        form['j_password']=Digest::MD5.hexdigest(password)
        @page = form.submit
        binding.pry
      when :ustb
        @base_url = 'http://wiki.ibeike.com/index.php'
        @public_class='北京科技大学公共选修课列表'
        @departments = ['土木与环境工程学院','冶金与生态工程学院','材料科学与工程学院','机械工程学院','计算机与通信工程学院','自动化学院','数理学院','化学与生物工程学院','东凌经济管理学院','文法学院','外国语学院']      
        @lista = ['土木与环境工程学院','冶金与生态工程学院','材料科学与工程学院','机械工程学院','信息工程学院','数理&化生学院','东凌经济管理学院','文法学院','外国语学院','体育部','图书馆信息咨询部','体育部','武装部','团委']
      when :buaa
        @base_url = 'http://jiaohu.buaa.edu.cn/G2S/ShowSystem/CourseList.aspx?OrgID='
      when :ruc
        @base_url = '/Users/Liber/Desktop/ruc/ruc.htm'
        @base_url2010_2021 = '/Users/Liber/Desktop/ruc/s_xuanke.htm'
        @base_url2005_2021 = '/Users/Liber/Desktop/ruc/xuanke.htm'
      end
    end

    def ruc_snatch_all_course_department(is_all=false)
      if !is_all
        tpage = open("#{@base_url2010_2021}").read
      else
        tpage = open("#{@base_url2005_2021}").read
      end
      thtml = Nokogiri::HTML(tpage)
      tea = Hash.new
      thtml.xpath('//table/tr').each_with_index do |tr,tr_index|
       if !thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text().nil? and !thtml.xpath("//table/tr[#{tr_index+2}]/td[10]").text().blank?
         if tea[thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text()].nil? 
           tea[thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text()] = [thtml.xpath("//table/tr[#{tr_index+2}]/td[10]").text().encode('utf-8')].to_set
           puts thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text() + ":" + tea[thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text()].to_a.to_s
         else 
           tea[thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text()] << thtml.xpath("//table/tr[#{tr_index+2}]/td[10]").text().encode('utf-8')
           puts thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text() + ":" + tea[thtml.xpath("//table/tr[#{tr_index+2}]/td[5]").text()].to_a.to_s
         end
       end
      end
      puts tea
      data = open("#{@base_url}").read
      html = Nokogiri::HTML(data)
      
      html.xpath('//table/tr').each_with_index do |tr,tr_index|
        tds = html.xpath("//table/tr[#{tr_index+2}]/td")
        if  !tds[0].nil? and !tds[0].text().blank? and !tds[1].nil? and !tds[1].text().blank?
          c_num = tds[0].text()
          c_name = tds[1].text()
          c_yuanxi = tds[2].text().blank? ? '通用' : tds[2].text()
          c_type = tds[3].text()
          # c_xuefen = tds[4].text()
          c_english_name = tds[8].text()
          c_body = tds[11].text().blank? ? '-' : tds[11].text()
          c_teacher = tea[c_num].to_a
          puts c_num + ":" + c_name + ":" + c_yuanxi + ":" + c_type + ":" + ":" +c_english_name + ":"  + c_teacher.to_s
          # department = Department.find_or_create_by(name:c_yuanxi)
          # course = Course.find_or_initialize_by(number:c_num)
          # course.ctype = c_type
          # course.name = c_name
          # course.english_name = c_english_name
          # course.department = department.name
          # course.desc = c_body
          # course.save(:validate=>false)
          # tea[c_num].each do |t|
          #   teaching = course.teachings.find_or_initialize_by(teacher:t)
          #   teaching.save(:validate=>false)
          # end
          # puts course.number + ':' + course.name + ':' +  course.ctype + ':' + course.department
        end
        # each_with_index do |td,td_index|
        #           puts td.text()
        #         end
      end

      binding.pry
      
    end
    
    
    def psvr_clean(str)
      str.split(" ").join('').strip
    end
    
   def touch_course_departments_buaa
        for i in 1..42 do  
          data = open("#{@base_url}#{i.to_s}").read
          # actual [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 37, 38, 39, 40, 42] is not empty
          xmldoc = Nokogiri::XML(data)
          c_type = '学院课程'
          d_name = xmldoc.xpath('//DataSource//CourseBrief//fOrganizationName').text()
          department = Department.find_or_create_by(name:d_name)
          xmldoc.xpath('//DataSource//CourseList').each_with_index do |cl,index|
            c_name = xmldoc.xpath("//DataSource//CourseList[#{index}]//fCourseName").text()
            c_num = xmldoc.xpath("//DataSource//CourseList[#{index}]//fCourseNo").text()
            if !c_name.blank?
                course = Course.find_or_create_by(number:c_num)
                course.ctype = c_type
                course.name = c_name
                course.department = department.name
                course.save(:validate=>false)
                puts course.number + ':' + course.name + ':' +  course.ctype + ':' + course.department
            end
          end
       end
   end
    # for ustb-ibeike
   def touch_courses_departments_ustb_college
      for i in 0..(@departments.length-2) do
        @page = @agent.get("#{@base_url}/#{@departments[i]}课程设置")
        parser=@page.parser
        parser.css('.wikitable tr').each do |tr|
          tds = tr.css('td')
          next unless tds.count > 0
          department = Department.find_or_create_by(name:@departments[i])
          if i==0 || i==1 || i==2
            c_type = psvr_clean(tds[1].text)
            c_num = psvr_clean(tds[2].text)
            c_name = psvr_clean(tds[3].text)
          else
            c_type = psvr_clean(tds[0].text)
            c_num = psvr_clean(tds[1].text)
            c_name = psvr_clean(tds[2].text)
          end
          if !c_name.blank?
            course = Course.find_or_initialize_by(number:c_num)
            course.ctype = c_type
            course.name = c_name
            course.department = department.name
            course.save(:validate=>false)
            puts course.number + ':' + course.name + ':' +  course.ctype
          end
        end
      end
    end
    def touch_course_department_public_ustb
      @page = @agent.get("#{@base_url}/#{@public_class}")
      parser=@page.parser
      c_type = '公共选修'
      c_num = 'public'
      parser.css('#bodyContent ul').each_with_index do |ul,index|
        if index >=2 && index<=15
          ul.css('li').each_with_index do |li,li_index|
              c_nums = c_num + '_' + (index-2).to_s + '_' + li_index.to_s
              c_name = psvr_clean(li.text())
              
              department = Department.find_or_create_by(name:@lista[index-2])
              course = Course.find_or_initialize_by(number:c_nums)
              course.ctype = c_type
              course.name = c_name
              course.department = department.name
              course.save(:validate=>false)      
              puts course.number + ':' + course.name + ':' + course.ctype + ':' + course.department
          end
        end
      end
    end
    # for cnu
    def touch_courses_teachings_departments_teachers
      @page = @agent.get("#{@base_url}/courseSearchAction.do?temp=1")
      form = @page.forms.first
      multiselectlist = form.field_with(:name=>'showColumn')
      multiselectlist.select_all
      @page = form.submit
      next_paged = true
      while next_paged
        parser=@page.parser
        parser.css('#user tr').each do |tr|
          tds = tr.css('td')
          next unless tds.count > 0
          department = Department.find_or_create_by(name:psvr_clean(tds[0].text))
          course = Course.find_or_create_by(number:psvr_clean(tds[1].text))
          course.name = psvr_clean(tds[2].text)
          course.department = department.name
          teaching = course.teachings.find_or_create_by(teacher:psvr_clean(tds[6].text.gsub('*','')))
          teaching.credit = psvr_clean(tds[4].text).to_f
          teaching.judge = psvr_clean(tds[5].text)
          teaching_klass = teaching.teaching_klasses.find_or_create_by(number: psvr_clean(tds[3].text))
          teaching_klass.weekspan = psvr_clean(tds[7].text)
          teaching_klass.weekday = psvr_clean(tds[8].text)
          teaching_klass.klassnum = psvr_clean(tds[9].text)
          teaching_klass.geo_location = psvr_clean(tds[10].text)
          teaching_klass.geo_building = psvr_clean(tds[11].text)
          teaching_klass.geo_classroom = psvr_clean(tds[12].text)
          teaching_klass.capacity = psvr_clean(tds[13].text)
          teaching_klass.stu_size = psvr_clean(tds[14].text)
          teaching_klass.save(:validate=>false)
          teaching.save(:validate=>false)
          course.save(:validate=>false)
          puts course.name
        end
        next_paged = false
        @page.links.each do |link|
          if "下一页"==link.text
            @page = link.click
            next_paged = true
            break
          end
        end
      end
    end
    

    def touch_all_courses
      last=nil
      ins=nil
      did_something = true
      pagenum = 0
      special_cnu = Ktv::Spider.new
      special_cnu.start_mode(:cnu,'1090500165','pmqpmq55')
      specialAgent = special_cnu.agent

      while(did_something)
        did_something = false
        pagenum += 1
        @agent.get("#{@baseurl}/kclbAction.do?oper=kclb")
        @agent.get("#{@baseurl}/kclbAction.do?totalrows=11575&page=#{pagenum.to_s}&pageSize=100")
        agent=@agent
        agent.page.search('tr').each{|f| next unless f.inspect=~/课程信息查看/;
          next unless f.children[2];
          f.children[2].to_s=~/\r\n\t\t\t\t\t\t\t\t\t\t\t(.*)\r\n\t\t\t\t\t\t\t\t\t\t/;
          number = $1.encode('utf-8').strip
          f.children[6].to_s=~/\r\n\t\t\t\t\t\t\t\t\t\t\t(.*)\r\n\t\t\t\t\t\t\t\t\t\t/;
          next unless $1
          next if ''==$1.strip
          if last!=$1.encode('utf-8').strip
          ins=Department.where(name:$1.encode('utf-8').strip).first
            unless ins
            ins = Department.create!(name:$1.encode('utf-8').strip)
            print "Department.create!(name:#{$1.encode('utf-8').strip})\n"
            end
          last=$1.encode('utf-8').strip
          end
          f.children[8].to_s=~/\r\n\t\t\t\t\t\t\t\t\t\t\t(.*)\r\n\t\t\t\t\t\t\t\t\t\t/;
          ben_yan = $1.encode('utf-8').strip
          f.children[4].to_s=~/\r\n\t\t\t\t\t\t\t\t\t\t\t(.*)\r\n\t\t\t\t\t\t\t\t\t\t/;
          name = $1.encode('utf-8').strip
          specialAgent.get("http://202.204.208.75/kcxxAction.do?oper=kcxx_if&kch=#{number}")
          bulk = specialAgent.page.search('tr').first.inspect
          bulks = bulk.try(:split,/课程号|课程名|英文课程名|开课院系|开课学期|本研标志|学分|学时|开始日期|结束日期|学科门类|实践周数|课内周学时|设计总学时|课程类别|课程级别|其中上机总学时|试验总学时|课程状态|课外学分|设计作业总学时|课外总学时|收费类别|教学方式|讨论辅导总学时|授课总学时|校区|考试类型|人数系数代码|课时费类别代码|标准人数|教师|师资队伍|教材|参考书|课程说明|内容 简介|英文内容简介|备注|教学大纲|英文教学大纲|主要修课对象/)
          x = Course.where(number:number).first
          puts "[#{number}]#{x ? '' : 'new' } #{name}"
          x ||= Course.new
          x.number=number
          x.name=name
          x.is_yjs=ben_yan
          x.department=ins.name
          #todo try split
          x.eng_name=bulks[3].split(',')[4].split('children=')[1].encode('utf-8').split('"')[1].strip
          x.credit=bulks[7].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.credit_hours=bulks[8].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.jiaoxuefs=bulks[24].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.neirongjianjie=bulks[37].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.book1=bulks[34].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.book2=bulks[35].split('children=')[1].split(',')[0].split('"')[1].encode('utf-8').strip
          x.save(:validate=>false)
          did_something=true
        }
      end
    end
  end
end
