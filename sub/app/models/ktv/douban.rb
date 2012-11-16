# -*- encoding : utf-8 -*-
module Ktv
  class Douban
    extend Ktv::Helpers::Config
    include Ktv::Helpers::Config
    GET_BOOK_VIA_ISBN = 'http://api.douban.com/book/subject/isbn/'
    def self.get_book_via_isbn(isbn,opts={})
      return {} if isbn.blank?
      response = JQuery.ajax(:type => 'GET',
        :accept => 'text/xml',
        :url => "#{GET_BOOK_VIA_ISBN}#{isbn}",
        :data => {}
      )
      ret = Utils.safely{
        JSON.parse(Hash.from_xml(response).to_json)
      }
      return {} if ret.blank? or ret['entry'].blank?
      ret['entry']
    end
  end
end
