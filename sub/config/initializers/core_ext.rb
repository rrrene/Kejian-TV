# -*- encoding : utf-8 -*-
require 'iconv'
class String
  def force_encoding_zhaopin
    begin
      Iconv.conv('gbk','utf-8',self)
    rescue => e
      begin
        return Iconv.conv('utf-8','gbk',self)
      rescue => e
        return self
      end
    end
    return self
  end   
end

class Array
  def limit(num)
    if self.count > num
      self[0..num-1]
    else
      self
    end
  end
  def rlimit(num)
    if self.count > num
      self[-num..-1]
    else
      self
    end
  end
  
  # returns if we really detected some deleted or non-existent stuff
  def make_sure_existance(klass,field=nil)
    self2 = self.dup
    ret = false
    self2.each do |id|
      begin
        if !field
          instance = klass.find(id)
        else
          instance = klass.where(field=>id).first
          raise 'deleted' if !instance
        end
        raise 'deleted' if 1==instance.deleted
      rescue
        self.delete id
        ret = true
      end
    end
    ret
  end

end

# 
# ActiveSupport::Notifications.subscribe("active_reload.set_clear_dependencies_hook_replaced") do |*args|
#   event = ActiveSupport::Notifications::Event.new(*args)
#   msg = event.name
#   # Ubuntu: https://github.com/splattael/libnotify, Example: Libnotify.show(:body => msg, :summary => Rails.application.class.name, :timeout => 2.5, :append => true)
#   # Macos: http://segment7.net/projects/ruby/growl/
#   puts Rails.logger.warn(" --- #{msg} --- ")
# end
# 
# ActiveSupport::Notifications.subscribe("active_support.dependencies.clear") do |*args|
#   msg = "Code reloaded!"
#   # Ubuntu: https://github.com/splattael/libnotify, Example: Libnotify.show(:body => msg, :summary => Rails.application.class.name, :timeout => 2.5, :append => true)
#   # Macos: http://segment7.net/projects/ruby/growl/
#   puts Rails.logger.info(" --- #{msg} --- ")
# end
