# -*- encoding : utf-8 -*-
module Ktv
  class Google
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    TRANSLATOR = 'https://www.googleapis.com/language/translate/v2'
    # API key. Use the `key` query parameter to identify your application.
    # Target language. Use the `target` query parameter to specify the language you want to translate into.
    # Source text string. Use the `q` query parameter to identify the string to translate.
    def self.translate(q,opts={})
      return '' if q.blank?
      opts[:source] ||= 'zh-CN'
      opts[:target] ||= 'en'
      response = JQuery.ajax(:type => 'GET',
        :url => TRANSLATOR,
        :data => {
          :key => config.google_simple_api_key,
          :q => q,
          :source => opts[:source],
          :target => opts[:target]
        }
      )
      return '' if response.nil?
      ret = Utils.safely{response['data']['translations'][0]['translatedText']}
      return '' if ret.blank?
      ret.strip
    end
  end
end
