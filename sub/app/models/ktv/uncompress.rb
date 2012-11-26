# -*- encoding : utf-8 -*-
require 'rubygems'
require 'zip/zip'
require 'find'
require 'fileutils'

module Ktv
  class Uncompress
    def self.perform(id)
        @filter = ['pdf','djvu','ppt','pptx','doc','docx']
        @blacklist = ['git','svn','ds_store','exe','obj','db','app','jar']
        @courseware = Courseware.find(id)
        @courseware.make_sure_globalktvid!
        if @courseware.tree.present?
          tmp = @courseware.tree.to_s.scan(/"id"=>"([a-z0-9]{20,})"/).compact.flatten
          tmp.each do |t|
            c = Courseware.find(t)
            if c.redirect_to_id.present?
              c.soft_delete
              c.delete
            end
          end
        end
        @title = @courseware.title
        sort=File.extname(@courseware.pdf_filename).split('.')[-1].to_s.downcase
        @courseware.update_attribute(:pdf_slide_processed,0)
        @working_dir = "/media/hd2/auxiliary_#{Setting.ktv_sub}/ftp/cw/#{@courseware.id}" #$psvr_really_production ? : "#{Rails.root}/simple/tmp/uncompress_#{Setting.ktv_sub}/#{@courseware.id}_#{sort}"
        begin
          uncom_path = "#{@working_dir}/#{@courseware.pdf_filename.gsub(".","_")}"
          `mkdir -p "#{@working_dir}"`
          `mkdir "#{uncom_path}"`
           if @courseware.really_localhost
             puts cmd=%Q{cp "#{@courseware.really_localpath}" "#{@working_dir}/#{File.basename(@courseware.remote_filepath)}"}
             puts `#{cmd}`
           else 
             `curl "#{@courseware.remote_filepath}" -o "#{@working_dir}/#{File.basename(@courseware.remote_filepath)}"`
           end
           compressed_path = "#{@working_dir}/#{File.basename(@courseware.remote_filepath)}"

           @courseware.fileinfo_raw = Ktv::Utils.safely(''){`file "#{compressed_path}"`.force_encoding_zhaopin.strip.split(': ')[1..-1].join(': ')}
           @courseware.dz_file_manipulate
           if(@courseware.md5.blank?)
              md5 = @courseware.md5 = Digest::MD5.hexdigest(File.read(compressed_path))
              @courseware.md5hash[@courseware.version.to_s] = md5
              @courseware.md5s = 0.upto(@courseware.version).collect{|md5_i| @courseware.md5hash[md5_i.to_s]}
              if md5_cw = Courseware.where('md5s'=>md5).first
                @courseware.update_attribute(:redirect_to_id,md5_cw.id)
                @courseware.redirect_to_id_op
                @courseware.update_attribute(:status,0)
                return
              end 
            end
           #------------------------zipfile to snda
            zipfile="#{@working_dir}/#{@courseware.id}#{@courseware.revision}.zip"
            puts `zip -j "#{zipfile}" "#{compressed_path}"`
            done = false
            psvr_count=0
            while !done and psvr_count<10
              psvr_count+=1
              begin
                new_object = $snda_ktv_down.objects.build("#{@courseware.ktvid}#{@courseware.revision}.zip")
                new_object.content = open(zipfile)
                new_object.save
                done = true
              rescue => e
                puts e
              end
            end
            @courseware.update_attribute(:down_pdf_size,File.size(zipfile)/1000)
            #---------          
            tree = Hash.new
            case sort.to_sym
            when :zip
              tree = unzip(compressed_path,uncom_path)
            when :rar
              tree = unrar(compressed_path,uncom_path)
            when :'7z'
              tree = un7zip(compressed_path,uncom_path)
            end
            @courseware.forest[@courseware.version.to_s]=@courseware.tree=tree
            @courseware.width = 694
            @courseware.height = 523
            @courseware.status = 4
            if @courseware.get_children.blank?
              @courseware.status = 0
            end
            @courseware.save(:validate => false)
            # puts `rm -rf "#{@working_dir}"`
            return tree
        rescue => e
            @courseware.status = -1
            @courseware.save(:validate=>false)
            raise e
        end          

    end    
    
    def self.unzip(filename,dest_path,remove_after = false)
      unzip_recursive(filename,dest_path)
      
      rar_inzip = `find #{dest_path} -iname '*.rar' -exec ls {} +\;`.split("\n")
      rar_inzip.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`unrar x -inul -o+ -r #{x} #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`} 
      p7zip_inzip = `find #{dest_path} -iname '*.7z' -exec ls {} +\;`.split("\n")
      p7zip_inzip.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`7z x -y -r -o#{File.join(File.dirname(x),File.basename(x).gsub('.','_'))} #{x}`}
      
      Dir["#{dest_path}/**/*"].select { |d| File.directory? d }.select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } .each{ |d| Dir.rmdir d }    #delete empty dir

      `find #{dest_path} -iname '*.rar' -exec rm -f {} +\;`
      `find #{dest_path} -iname '*.7z' -exec rm -f {} +\;`

      process_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.select{|d| @filter.include?(File.extname(d).split('.')[-1].to_s.downcase)}.count
      @courseware.slides_counts[@courseware.version.to_s]=@courseware.slides_count = process_count
      @courseware.save(:validate=>false)
      files_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.count
      @courseware.update_attribute(:files_count,files_count)
      hash = jsonize(dest_path)
      
      FileUtils.rm_rf(dest_path) if remove_after
      return hash
    end
    
    
    def self.unrar(filename,dest_path,remove_after = false)
      # binding.pry
      `unrar x -inul -o+ -r #{filename} #{dest_path}/`
      rar_inrar = `find #{dest_path} -iname '*.rar' -exec ls {} +\;`.split("\n")
      rar_inrar.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`unrar x -inul -o+ -r #{x} #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`}
   
      p7zip_inrar = `find #{dest_path} -iname '*.7z' -exec ls {} +\;`.split("\n")
      p7zip_inrar.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`7z x -y -r -o#{File.join(File.dirname(x),File.basename(x).gsub('.','_'))} #{x}`}
      zip_inrar = `find #{dest_path} -iname '*.zip'`.split("\n")
      zip_inrar.map {|x| unzip_recursive(x,File.join(File.dirname(x),File.basename(x).gsub('.','_')),true)}
      
      Dir["#{dest_path}/**/*"].select { |d| File.directory? d }.select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } .each{ |d| Dir.rmdir d }    #delete empty dir
      `find #{dest_path} -iname '*.rar' -exec rm -f {} +\;`
      `find #{dest_path} -iname '*.7z' -exec rm -f {} +\;`
      
      process_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.select{|d| @filter.include?(File.extname(d).split('.')[-1].to_s.downcase)}.count
      @courseware.slides_counts[@courseware.version.to_s]=@courseware.slides_count = process_count
      @courseware.save(:validate=>false)
      files_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.count
      @courseware.update_attribute(:files_count,files_count)
      hash = jsonize(dest_path)

      FileUtils.rm_rf(dest_path) if remove_after
      return hash
    end
    
    def self.un7zip(filename,dest_path,remove_after = false)
      `7z x -y -r -o#{dest_path} #{filename}`
      
      p7zip_in7zip = `find #{dest_path} -iname '*.7z' -exec ls {} +\;`.split("\n")
      p7zip_in7zip.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`7z x -y -r -o#{File.join(File.dirname(x),File.basename(x).gsub('.','_'))} #{x}`}
      
      zip_in7zip = `find #{dest_path} -iname '*.zip'`.split("\n")
      zip_in7zip.map {|x| unzip_recursive(x,File.join(File.dirname(x),File.basename(x).gsub('.','_')),true)}
      rar_in7zip = `find #{dest_path} -iname '*.rar' -exec ls {} +\;`.split("\n")
      rar_in7zip.map{|x| `mkdir #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`;`unrar x -inul -o+ -r #{x} #{File.join(File.dirname(x),File.basename(x).gsub('.','_'))}`}
      
      Dir["#{dest_path}/**/*"].select { |d| File.directory? d }.select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } .each{ |d| Dir.rmdir d }    #delete empty dir
      `find #{dest_path} -iname '*.rar' -exec rm -f {} +\;`
      `find #{dest_path} -iname '*.7z' -exec rm -f {} +\;`
      
      process_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.select{|d| @filter.include?(File.extname(d).split('.')[-1].to_s.downcase)}.count
          @courseware.slides_counts[@courseware.version.to_s]=@courseware.slides_count = process_count
          @courseware.save(:validate=>false)

      files_count = Dir["#{dest_path}/**/*"].select { |d| !File.directory? d }.count
      @courseware.update_attribute(:files_count,files_count)
      hash = jsonize(dest_path)

      FileUtils.rm_rf(dest_path) if remove_after
      return hash
      
    end
    
    
    def self.unzip_recursive(filename,dest,recursive_remove_origin_after = false)
      Zip::ZipFile.open(filename) do |zip_file|
        files = zip_file.select(&:file?)
        files.reject!{|f| f.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/ }   #perfect to remove .DS_store __Macosx and some .git .svn
        files.each do |f|
          f_path = File.join(dest,f.name.force_encoding_zhaopin)
          FileUtils.mkdir_p(File.dirname(f_path))

          puts File.dirname(f_path)
          zip_file.extract(f, f_path) unless File.exist?(f_path)
          if !File.directory?(f_path) and File.extname(f_path).split('.')[-1] == 'zip'
            unzip_recursive(f_path,File.join(File.dirname(f_path),File.basename(f_path).gsub('.','_')),true)
          end
        end
      end
      FileUtils.rm_rf(filename) if recursive_remove_origin_after
    end
    
    def self.inject_family(opts={})
      p = {}
      p[:pdf_filename]=File.basename(opts[:pdf_filename])
      p[:title] = @title
      ## about child
      rest = opts[:filepath].split(@working_dir)[-1].split("/").collect{|x| URI::escape(x.to_s)}.join("/")
      p[:is_children] = true
      p[:father_id] = @courseware.id
      p[:where_am_i_in_this_family] =  rest
      p[:child_rank] = @courseware.injected_count
      @courseware.update_attribute(:injected_count,@courseware.injected_count+1)
      ## end child

      if ['ppt','pptx','doc','docx'].include? opts[:sort].downcase
        p[:remote_filepath]="http://special_agentx.#{Setting.ktv_domain}/#{@courseware.id}#{rest}"
      else
        p[:remote_filepath]=opts[:filepath]
      end
      p[:sort] = opts[:sort]
      p[:really_localhost]=true
      p[:really_localpath]=opts[:filepath]
      p[:subsite] = opts[:subsite]
      p[:id] = nil
      # p[:tid]= @courseware.tid
      user = @courseware.uploader
      Courseware.presentations_upload_finished(p,user)
    end

    def self.jsonize(dest_path)
      FileUtils.chmod_R(0755,dest_path)
      json = directory_hash(dest_path,@title)
      json = {:id => 'Root',:open=>"1",:select => "1",:child => "1"}.merge(json)
      json = {:id => 0,:item => [json]}
      return json
    end

    def self.directory_hash(path, name=nil,step=0)
      data = {:text => (name || path)}
      data[:item] =item = []
      
      Dir.foreach(path) do |entry|
        next if (entry == '..' || entry == '.')
          full_path = File.join(path, entry)
          if File.directory?(full_path)            
            if step < 2
              item << {:id=>"dir_" + Ktv::Utils.rand_one_string(10),:child => "1",:open => "1"}.merge(directory_hash(full_path, entry,step+1))
            else
              item << {:id=>"dir_" + Ktv::Utils.rand_one_string(10),:child => "1"}.merge(directory_hash(full_path, entry,step+1))
            end
          else
            tmp_id = ""
            im0 = 'leaf.gif'
            sort=File.extname(entry).split('.')[-1].to_s.downcase
            if @filter.include?(sort)
                opts={
                      :subsite=>Setting.ktv_sub,
                      :sort=>sort,
                      :pdf_filename=>entry,
                      :filepath=>full_path
                }
                tmp_cw = inject_family(opts)
                tmp_papa = Courseware.find(tmp_cw.father_id)
                # psvr add
                tmp_cw.update_attribute(:course_fid,tmp_papa.course_fid)
                # psvr add
                tmp_papa.update_attribute(:pdf_slide_processed,tmp_papa.pdf_slide_processed + 1)
                tmp_papa.update_attribute(:transcoding_count,tmp_papa.transcoding_count+1)
                #tmp_cw.update_attribute(:child_rank,tmp_papa.pdf_slide_processed + 1) 
                if tmp_cw.redirect_to_id.present?
                  tmp_id = tmp_cw.redirect_to_id.to_s
                else
                  tmp_id = tmp_cw.id.to_s
                end
                
                case sort.to_sym
                when :pdf,:djvu
                  im0 = 'iconTexts.gif'
                when :ppt,:pptx
                  im0 = 'iconGraph.gif'
                when :doc,:docx
                  im0 = 'iconWrite2.gif'
                end
                item << {id:tmp_id,text:entry,im0:im0}
            elsif !@blacklist.include?(sort)
                case sort.to_sym
                when :txt,:html,:js
                  im0 = 'iconText.gif'
                when :jpg,:jpeg,:png,:bmp,:gif,:tif,:tiff
                  im0 = 'iconFlag.gif'
                when :avi,:mkv,:rmvb
                  im0 = 'iconSound.gif'
                end
                item << {id:Ktv::Utils.rand_one_string(10),text:entry}
            end
            
          end
      end
      return data
    end
  end
end
