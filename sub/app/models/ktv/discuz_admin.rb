# -*- encoding : utf-8 -*-
module Ktv
  class DiscuzAdmin
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    include Shared::MechanizeParty
    ADMIN_USER = 'kejian.tv@gmail.com'
    ADMIN_PASS = 'jknlff8-pro-17m7755'
    def fill_user_info(uid,form)
      @page = @agent.get "http://#{base_url}/admincp.php?action=members&operation=edit&uid=#{uid}"
      dz_form = @page.forms.first
      form.fields.each do |x|
        next if 'hidden'==x.type
        dz_form[x.name]=x.value
      end
      dz_form.submit
    end
    def start_mode(mode)
      @mode = mode
      @base_url = "http://#{@mode}.#{Setting.ktv_domain}/simple"
      # 依赖于forum.php显示登陆框框
      @login_page = @agent.get("#{@base_url}/member.php?mod=logging&action=login")
      form = @login_page.form_with(:name=>'login')
      if(form)
        form.username = ADMIN_USER
        form.password = ADMIN_PASS
        @page = form.submit
      else
        raise 'no login form?'
      end
      @login_page = @agent.get("#{@base_url}/admin.php")
      form = @login_page.form_with(:id=>'loginform')
      if form
        form.admin_password = ADMIN_PASS
        @page = form.submit
      end
    end
    
    def start_mode_with_out_admin(mode=nil)
        @mode = mode
        if @mode.present?
          @base_url = "http://#{@mode}.kejian.#{$psvr_really_development ? 'lvh.me' : 'tv' }/simple"
        else
          @base_url = "http://kejian.#{$psvr_really_development ? 'lvh.me' : 'tv' }/simple"
        end
        puts @base_url
        # 依赖于forum.php显示登陆框框
        @login_page = @agent.get("#{@base_url}/forum.php?mod=post&action=newthread&fid=61")
        form = @login_page.form_with(:id=>'lsform')
        if(form)
          form.username = ADMIN_USER
          form.password = ADMIN_PASS
          @page = form.submit
        end
    end
    
    def publish_thread(fid,course,mode=nil)
      @mode = mode
      if @mode.present?
        @base_url = "http://#{@mode}.kejian.#{$psvr_really_development ? 'lvh.me' : 'tv' }/simple"
      else
        @base_url = "http://kejian.#{$psvr_really_development ? 'lvh.me' : 'tv' }/simple"
      end
      # puts url = "/forum.php?mod=forumdisplay&fid=#{fid}"
      # "http://ibeike.kejian.lvh.me/simple/forum.php?mod=post&action=newthread&fid=61"
      @login_page = @agent.get("#{@base_url}/forum.php?mod=post&action=newthread&fid=61")
      form = @login_page.form_with(:id=>'lsform')
      if(form)
        form.username = ADMIN_USER
        form.password = ADMIN_PASS
        @page = form.submit
      end
      
      puts url = "#{@base_url}/forum.php?mod=post&action=newthread&fid=#{fid}"
      @post_page = @agent.get(url)
      parser = @post_page.parser
      form = @post_page.form_with(:id => 'postform')
      if(form)
          # binding.pry
          form['typeid'] = '其他'
          form['psvr_teacher_new'] = course.teacher
          form['subject']= course.title
          form['message']= Nokogiri::HTML(course.description).text
          @page = form.submit
      end
    end
  
    def edit_thread_title_teacher(fid,tid,teachername)
      # http://ibeike.kejian.lvh.me/simple/forum.php?mod=post&action=edit&fid=1958&tid=4276&pid=4276&page=1
        puts url = "#{@base_url}/forum.php?mod=post&action=edit&fid=#{fid}&tid=#{tid}&pid=#{tid}"
        @post_page = @agent.get(url)
        parser = @post_page.parser
        form = @post_page.form_with(:id => 'postform')
        if(form)
            tc = PreForumThreadclass.where(fid:fid,name:teachername).first
            typeid = tc.nil? ? nil : tc.typeid
            form['typeid'] = typeid
            if form['subject'].include?(teachername)  
              form['subject'].gsub("[#{teachername}]",'')
            end
            @page = form.submit
        end
    end
    def edit_thread_inject_js(fid,tid)
      # http://ibeike.kejian.lvh.me/simple/forum.php?mod=post&action=edit&fid=1958&tid=4276&pid=4276&page=1
        puts url = "#{@base_url}/forum.php?mod=post&action=edit&fid=#{fid}&tid=#{tid}&pid=#{tid}"
        @post_page = @agent.get(url)
        parser = @post_page.parser
        form = @post_page.form_with(:id => 'postform')
        if(form)
            tc = PreForumThreadclass.where(fid:fid,name:teachername).first
            typeid = tc.nil? ? nil : tc.typeid
            form['typeid'] = typeid
            if form['subject'].include?(teachername)  
              form['subject'].gsub("[#{teachername}]",'')
            end
            @page = form.submit
        end
    end

    def add_teacher_from_thread(fid,teacher_name)
        puts url = "#{@base_url}/admin.php?action=forums&operation=edit&fid=#{fid}"
        @page = @agent.get(url)
        parser = @page.parser
        form = @page.forms.last
        form['threadtypesnew[status]']='1'
        form['threadtypesnew[required]']='1'
        form['threadtypesnew[listable]']='1'
        form['threadtypesnew[prefix]']='1'
        if parser.css("input[value='#{teacher_name}']").present?
            puts "#{teacher_name} exists."
        else
          index = parser.css("input[size='2']").last[:value].to_i
          form.add_field!('newdisplayorder[]',"#{index+1}");form.add_field!('newname[]',teacher_name);form.add_field!('newicon[]','');form.add_field!('newenable[]','1');form.add_field!('newmoderators[]','')
          form['detailsubmit']='提交'
          form.submit
        end
    end

    def orthodoxize_course_forums!
      Course.all.each do |item|
        begin
          self.orthodoxize_course item
        rescue=>e
          puts e
        end
      end
    end
    def orthodoxize_course(item)
      puts url = "#{@base_url}/admin.php?action=forums&operation=edit&fid=#{item.fid}"
      @page = @agent.get(url)
      parser = @page.parser
      form = @page.forms.last
      form['threadtypesnew[status]']='1'
      form['threadtypesnew[required]']='1'
      form['threadtypesnew[listable]']='1'
      form['threadtypesnew[prefix]']='1'
      item.teachings.each_with_index do |tch,index|
        if parser.css("input[value='#{tch.teacher}']").present?
          puts "#{tch.teacher} exists."
          next
        end
        form.add_field!('newdisplayorder[]',"#{index+1}");form.add_field!('newname[]',tch.teacher);form.add_field!('newicon[]','');form.add_field!('newenable[]','1');form.add_field!('newmoderators[]','')
      end
      form['detailsubmit']='提交'
      form.submit
    end
  end
end

