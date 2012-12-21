# -*- encoding : utf-8 -*-
module Ktv
  class Utils
    def self.hashcat(hash)
      hash.collect do |key,val|
        "key=#{URI::escape(val.to_s)}"
      end.join('&')
    end
    def self.assert(statement)
      ret = statement
      if !ret
        raise Shared::ScriptNeedImprovement
      end
    end
    def self.find_in_batch(klass,field,arr)
      {}.tap do |h|
        if klass.ancestors.include?(ActiveRecord::Base)
          klass.where(field=>arr).each do |inst|
            h[inst.send(field)]=inst
          end
        else
          klass.where(field.in=>arr).each do |inst|
            h[inst.send(field)]=inst
          end
        end
      end
    end
    # To execute the block code in a exception-free manner
    # all exceptions are sent to the logger on the error level for inspection.
    # returns nil on error
    def self.safely(ret=nil,&block)
      return yield
    rescue => e
      Ktv.config.logger.error "#{e}"
      return ret
    end

    def self.get_parser(page)
      if page.encoding_error?
        return Nokogiri::HTML( page.body.getout_from(page.encoding) )
      else
        return page.parser
      end
    end
    
    def self.js_strlen(str)
      len=0
      i=0
      while i<str.length
        if str[i].ord>255
          len+=2
        else
          len+=1
        end
        i+=1
      end
      return len
    end
  
    def self.js_chinese(str)
      ret=0
      i=0
      while i<str.length
        if str[i].ord>255
          ret+=1
        end
        i+=1
      end
      return ret
    end
    def self.rand_one_string(len)
      @hash = ''
      @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
      @max = @chars.length - 1
      for i in 0...len
        @hash += @chars[Random.rand(@max)]
      end
      return @hash
    end
  end
end
