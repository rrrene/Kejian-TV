# -*- encoding : utf-8 -*-
module Ktv
  # Adopt some methods from the front-end JQuery lib
  class JQuery
    #c.f. http://api.jquery.com/jQuery.ajax/
    def self.ajax(settings={})
      settings = settings.with_indifferent_access
      config = Ktv.config
      settings[:accept] ||= :json
      begin
        if 'POST'==settings[:type]
          resource = RestClient::Resource.new(settings[:url], :open_timeout => config.open_timeout, :timeout => config.timeout)
          data = settings[:data]
          data = settings[:data].to_json if :json==settings[:contentType]
          h={:content_type => settings[:contentType], :accept => settings[:accept],'User-Agent' => settings['User-Agent'],'COOKIE' => settings['COOKIE'],'Referer' => settings['Referer']}
          response = resource.post(data, h)
        elsif 'GET'==settings[:type]
          url_assembly = settings[:url]
          url_assembly += '?'+settings[:data].to_a.collect{|hash_item|
            "#{hash_item[0]}=#{CGI::escape(hash_item[1].to_s)}"
          }.join('&') unless settings[:data].blank?
          resource = RestClient::Resource.new(url_assembly, :open_timeout => config.open_timeout, :timeout => config.timeout)
          response = resource.get({:accept => settings[:accept],'User-Agent' => settings['User-Agent'],'COOKIE' => settings['COOKIE'],'Referer' => settings['Referer']})
        else
          raise 'Note: Other HTTP request methods, such as PUT and DELETE, can also be used here, but they are not supported by me yet.'
        end
        if settings[:psvr_original_response]
          # the response contains more info than a simple string
          return response
        else
          # only return the string
          response = response.to_s
          if settings[:ibeike_special_treatment]
            response = response.split('encoding="ISO-8859-1"').join('encoding="UTF-8"')
          end
          config.logger.debug "#{response}"
          if :json==settings[:accept]
            return MultiJson.load(response)
          elsif :xml==settings[:accept]
            return Ktv::Utils.safely(response.to_s){Hash.from_xml(response)}
          else
            return response
          end
        end
      rescue => e
        config.logger.error "#{e}"
        config.logger.error "#{e.class}"
        config.logger.error "#{e.backtrace}"
        if settings[:psvr_response_anyway]
          return response ? response : e
        else
          return nil
        end
      end
    end
  end
  # end of JQuery
end
