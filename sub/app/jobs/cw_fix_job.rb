# -*- encoding : utf-8 -*-
class CwFixJob
  include Sidekiq::Worker
  sidekiq_options :queue => :transcoding
  # c.f.
  # def snda_force(build,o);suc = false;while !suc;begin;new_object = $snda_ktv_eb.objects.build(build);new_object.content = open(o);new_object.save;rescue=>e;puts 'retry...';end;suc=true;end;end
  #
  # %w{5051d7c5e138230b81000002 5050acd0e138236e2c00007e 5050acd0e138236e2c000081 5050acd0e138236e2c000083  5050acd0e138236e2c00007d }.each{|cw_id| @courseware=Courseware.find(cw_id);working_dir = "/media/hd2/auxiliary/ftp/cw/#{@courseware.id}";0.upto(@courseware.slides_count-1){|i| puts pic = "#{working_dir}/#{@courseware.revision}slide_#{i}.jpg";snda_force("#{@courseware.id}/#{@courseware.revision}slide_#{i}.jpg",pic)};puts zipfile="#{working_dir}/#{@courseware.id}#{@courseware.revision}.zip"; snda_force("#{@courseware.id}#{@courseware.revision}.zip",zipfile);}
  #
  #
  #
  # Courseware.where(:check_upyun_result=>false,:status=>0,:really_broken.ne=>true,:slides_count.gt=>0).each{|x|  CwFixJob.perform_async(x.id)}
  def perform(id)
    @courseware = Courseware.find(id)
    return false unless 0==@courseware.status
    working_dir = "/media/hd2/auxiliary_#{Ktv.sub}/ftp/cw_fix/#{@courseware.id}"
    `mkdir -p "#{working_dir}"`
    0.upto(@courseware.slides_count-1) do |i|

            done = false
            tried_times = 0
            while !done
              begin
                tried_times += 1
                break if tried_times > 10
                puts pic = "#{working_dir}/#{@courseware.revision}slide_#{i}.jpg"
      `curl "http://storage-huabei-1.sdcloud.cn/ktv-eb/#{@courseware.id}/#{@courseware.revision}slide_#{i}.jpg" > "#{pic}"`
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
                  end
                end
                puts pic2 = "#{working_dir}/#{@courseware.revision}thumb_slide_#{i}.jpg"
                puts `convert "#{pic}" -thumbnail '210x>' -crop 210x158+0+0 +repage -gravity North "#{pic2}"`
                done = true
              rescue => e
                puts e
              end
            end

    end
    really_broken = 0
    while true
      really_broken += 1
      puts `#{Rails.root}/bin/ftpupyun_pic "#{working_dir}" "/cw/#{@courseware.id}/" "#{@courseware.revision}"`
      @courseware.check_upyun
      break if @courseware.check_upyun_result
      if really_broken > 10
        @courseware.update_attribute(:really_broken,true)
        break
      end
    end
  end
end
