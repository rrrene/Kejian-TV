# -*- encoding : utf-8 -*-
class TranscoderJob
  include Sidekiq::Worker
  sidekiq_options :queue => :transcoding
  
  def info2page_size(info)
    info.each_with_index{|x,i|if x=~/page size/i;return info[i];end}
    nil
  end
  def f2i(s,t)
    ss = s.split('.')
    tt = t.split('.')
    ss[1]||=''
    tt[1]||=''
    if ss[1].length > tt[1].length
      tt[1] += '0'*(ss[1].length-tt[1].length)
    elsif ss[1].length < tt[1].length
      ss[1] += '0'*(tt[1].length-ss[1].length)
    end
    ["#{ss[0]}#{ss[1]}".to_i,"#{tt[0]}#{tt[1]}".to_i]
  end
  
  def perform(id)
    @courseware = Courseware.find(id)
    @courseware.make_sure_globalktvid!
    begin
      working_dir = "/media/hd2/auxiliary_#{Setting.ktv_sub}/ftp/cw/#{@courseware.id}"
      pdf_path = "#{working_dir}/#{@courseware.pdf_filename}"
      `mkdir -p "#{working_dir}"`
      if @courseware.remote_filepath
        if [:ppt,:pptx,:doc,:docx].include? @courseware.sort.to_sym 
          `cp /media/hd2/win_transcoding/#{@courseware.id}.pdf "#{pdf_path}"`
          if(!File.exists?(pdf_path))
            @courseware.update_attribute(:status,-3);return false
          end
        elsif @courseware.really_localhost
          `cp "#{@courseware.remote_filepath}" "#{pdf_path}"`
        elsif @courseware.really_remote
          `curl "#{@courseware.remote_filepath}" > "#{pdf_path}"`
        end
        if(@courseware.md5.blank?)
          md5 = @courseware.md5 = Digest::MD5.hexdigest(File.read(pdf_path))
          @courseware.fileinfo_raw = Ktv::Utils.safely(''){`file #{pdf_path}`.force_encoding_zhaopin.strip.split(': ')[1..-1].join(': ')}
          @courseware.dz_file_manipulate
          @courseware.md5hash[@courseware.version.to_s] = md5
          @courseware.md5s = 0.upto(@courseware.version).collect{|md5_i| @courseware.md5hash[md5_i.to_s]}
          if md5_cw = Courseware.where('md5s'=>md5).first
            @courseware.update_attribute(:redirect_to_id,md5_cw.id)
            @courseware.redirect_to_id_op
            @courseware.update_attribute(:status,0) # -2
            return
          end 
        end
        ext = File.extname(pdf_path).downcase
        if '.pdf'==ext || '.ppt'==ext || '.pptx'==ext || '.doc'==ext || '.docx'==ext
          info = `pdfinfo "#{pdf_path}"`.split("\n")
          if info = info2page_size(info)
            @courseware.pdf_size_note = info
            if info=~/([\d.]+)(\s*)x(\s*)([\d.]+)/
              @courseware.width,@courseware.height = f2i($1.strip,$4.strip)
            end
          end
          pdf = Grim.reap pdf_path
          @courseware.slides_counts[@courseware.version.to_s]=@courseware.slides_count = pdf.count
          @courseware.status = 2
          @courseware.pdf_slide_processed = 1 if !@courseware.pdf_slide_processed or @courseware.pdf_slide_processed<=0
          @courseware.save!
          pinpic_final = ''
          pdf.each_with_index do |page,i|
            next unless i+1 >= @courseware.pdf_slide_processed
            done = false
            tried_times = 0
            while !done
              begin
                tried_times += 1
                break if tried_times > 10
                puts pic = "#{working_dir}/#{@courseware.revision}slide_#{i}.jpg"
                page.save(pic,:width=>@courseware.slide_width)        
                new_object = $snda_ktv_eb.objects.build("#{@courseware.ktvid}/#{@courseware.revision}slide_#{i}.jpg")
                new_object.content = open(pic)
                new_object.save
                if 0==i
                  inf = `identify "#{pic}"`
                  if inf=~/JPEG (\d+)x(\d+)/
                    @courseware.update_attribute(:real_width, $1.to_i)
                    @courseware.update_attribute(:real_height, $2.to_i)
                  end
                  # ---pinpic---
                  pinpic = "#{working_dir}/pin.jpg"
                  puts `convert "#{pic}" -resize 222x +repage -gravity North "#{pinpic}"`
                  inf = `identify "#{pinpic}"`
                  if inf=~/JPEG (\d+)x(\d+)/
                    pinpic_final = "#{working_dir}/#{@courseware.revision}pin.1.#{$1}.#{$2}.jpg"
                    puts `mv "#{pinpic}" "#{pinpic_final}"`
                    @courseware.update_attribute(:pinpicname,File.basename(pinpic_final))
                    if @courseware.is_children and @courseware.child_rank == 0
                        tmp_papa = Courseware.find(@courseware.father_id)
                        tmp_papa.update_attribute(:pinpicname,File.basename(pinpic_final))
                    end
                  end
                end
                puts pic2 = "#{working_dir}/#{@courseware.revision}thumb_slide_#{i}.jpg"
                puts `convert "#{pic}" -thumbnail '210x>' -crop 210x158+0+0 +repage -gravity North "#{pic2}"`
                done = true
              rescue => e
                puts e
              end
            end
            @courseware.update_attribute(:pdf_slide_processed,i+2) unless i+2>@courseware.slides_count
          end
        elsif '.djvu'==ext
          cw = @courseware
          str = `djvudump #{pdf_path}|grep INFO`
          if str=~/DjVu (\d+)x(\d+)/
            @courseware.width = $1.to_i
            @courseware.height = $2.to_i
          end
          str = `djvudump #{pdf_path}|grep pages`
          if str=~/(\d+) pages/
            @courseware.slides_counts[@courseware.version.to_s]=@courseware.slides_count =$1.to_i
          end
          @courseware.status = 2
          @courseware.pdf_slide_processed = 1
          @courseware.save!
          pinpic_final = ''
          pdf.each_with_index do |page,i|
            next unless i+1 >= @courseware.pdf_slide_processed
            done = false
            tried_times = 0
            while !done
              begin
                tried_times += 1
                break if tried_times > 10
                puts pic = "#{working_dir}/#{@courseware.revision}slide_#{i}.jpg"
                puts `ddjvu -size=#{@courseware.slide_width}x#{(@courseware.slide_width/@courseware.wh_ratio).to_i} -page=#{i} -format=pnm "#{working_dir}" #{i}.pnm`
                puts `pnmtojpeg "#{working_dir}"/#{i}.pnm -quality=90 > "#{pic}"`
                
               ### page.save(pic,:width=>@courseware.slide_width)        
                new_object = $snda_ktv_eb.objects.build("#{@courseware.ktvid}/#{@courseware.revision}slide_#{i}.jpg")
                new_object.content = open(pic)
                new_object.save
                if 0==i
                  inf = `identify "#{pic}"`
                  if inf=~/JPEG (\d+)x(\d+)/
                    @courseware.update_attribute(:real_width, $1.to_i)
                    @courseware.update_attribute(:real_height, $2.to_i)
                  end
                  # ---pinpic---
                  pinpic = "#{working_dir}/pin.jpg"
                  puts `convert "#{pic}" -resize 222x +repage -gravity North "#{pinpic}"`
                  inf = `identify "#{pinpic}"`
                  if inf=~/JPEG (\d+)x(\d+)/
                    pinpic_final = "#{working_dir}/#{@courseware.revision}pin.1.#{$1}.#{$2}.jpg"
                    puts `mv "#{pinpic}" "#{pinpic_final}"`
                    @courseware.update_attribute(:pinpicname,File.basename(pinpic_final))
                    if @courseware.is_children and @courseware.child_rank == 0
                        tmp_papa = Courseware.find(@courseware.father_id)
                        tmp_papa.update_attribute(:pinpicname,File.basename(pinpic_final))
                    end
                  end
                end
                puts pic2 = "#{working_dir}/#{@courseware.revision}thumb_slide_#{i}.jpg"
                puts `convert "#{pic}" -thumbnail '210x>' -crop 210x158+0+0 +repage -gravity North "#{pic2}"`
                done = true
              rescue => e
                puts e
              end
            end
            @courseware.update_attribute(:pdf_slide_processed,i+2) unless i+2>@courseware.slides_count
          end
        else
          raise Ktv::Shared::ScriptNeedImprovementException
        end
        raise Ktv::Shared::ScriptNeedImprovementException if ["#{working_dir}/slide_*.jpg"].blank? 
        @courseware.update_attribute(:status,3)
        #------------------------zipfile
        zipfile="#{working_dir}/#{@courseware.id}#{@courseware.revision}.zip"
        puts `zip -j "#{zipfile}" "#{pdf_path}"`
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
        #--------------------------thumb
        #only puts /thumb_slide_* files upward
        really_broken = 0
        while true
          really_broken += 1
          puts `#{Rails.root}/bin/ftpupyun_pic "#{working_dir}" "/cw/#{@courseware.ktvid}/" "#{@courseware.revision}"`
          if @courseware.is_children
            tmp_papa = Courseware.find(@courseware.father_id)
            `mkdir -p #{working_dir}/father`
            `cp #{working_dir}/#{@courseware.revision}thumb_slide_0.jpg #{working_dir}/father/#{tmp_papa.revision}thumb_slide_#{@courseware.child_rank}.jpg`
            if @courseware.child_rank == 0
                `cp #{working_dir}/#{@courseware.revision}pin.* #{working_dir}/father/#{tmp_papa.revision}#{tmp_papa.pinpicname}`
            end
            puts `#{Rails.root}/bin/ftpupyun_pic "#{working_dir}/father/" "/cw/#{tmp_papa.ktvid}/" "#{tmp_papa.revision}"`
          end
          @courseware.check_upyun
          break if @courseware.check_upyun_result
          if really_broken > 10
            @courseware.update_attribute(:really_broken,true)
            break
          end
        end
        #------done
        puts `rm -rf "#{working_dir}"`
        if @courseware.is_children
          Sidekiq::Client.enqueue(HookerJob,"Courseware",nil,:push_trigger,@courseware.id) 
        end
        @courseware.go_to_normal unless @courseware.really_broken
        @courseware.update_attribute(:created_at,Time.now)
      end
    rescue => e
      @courseware.status = -1
      @courseware.save(:validate=>false)
      raise e
    end
  end
end

# Sidekiq.redis{|r| r.flushall}
# 1286.upto(1290){|i|Courseware.find(i).destroy}
