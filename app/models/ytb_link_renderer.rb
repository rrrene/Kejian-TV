# -*- encoding : utf-8 -*-
class YTBLinkRenderer < WillPaginate::ActionView::LinkRenderer
  class << self
    attr_accessor :sectionPagerKlass
    attr_accessor :base_url
    def initialize
      super
    end
  end
  @sectionPagerKlass = 'pager clearfix'
  @base_url = nil
  # Process it! This method returns the complete HTML string which contains
  # pagination links. Feel free to subclass LinkRenderer and change this
  # method as you see fit.
  def url(page)
    if self.class.base_url.blank?
      return super(page)
    else
      url_params = {}
      add_current_page_param(url_params, page)
      ret = @template.url_for(url_params)
      "#{self.class.base_url}?#{ret.split('?')[-1]}"
    end
  end
  def to_html
    html = pagination.map do |item|
      item.is_a?(Fixnum) ?
        page_number(item) :
        send(item)
    end.join(@options[:link_separator])
    
    @options[:container] ? html_container(html) : html
  end
    
  protected
  
  def page_number(page)
    unless page == current_page
      link(tag(:span,page,:class=>"yt-uix-button-content"), page, :class => "yt-uix-button yt-uix-sessionlink yt-uix-pager-page-num yt-uix-pager-button yt-uix-button-default", :title => "前往第#{page}页")
    else
      link(tag(:span,page,:class=>"yt-uix-button-content"), page, :class => "yt-uix-button yt-uix-sessionlink yt-uix-pager-page-num yt-uix-button-toggled yt-uix-pager-button yt-uix-button-default", :title => "前往第#{page}页")
    end
  end
    
  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    tag(:span,text,:class=>"page-numbers dots")
  end
    
  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, @options[:previous_label], 'yt-uix-button yt-uix-sessionlink yt-uix-pager-button yt-uix-button-default')
  end
    
  def next_page
    num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
    previous_or_next_page(num, @options[:next_label], 'yt-uix-button yt-uix-sessionlink yt-uix-pager-button yt-uix-button-default')
  end
    
  def previous_or_next_page(page, text, classname)
    if page
      link(tag(:span,text,:class=>"yt-uix-button-content"), page, :class => classname, :rel=>"#{classname}", :title => "前往第#{page}页")
    else
      ''
    end
  end
    
  def html_container(html)
    '<div class="comments-pagination">'+tag(:div, html, container_attributes.merge(:class => 'yt-uix-pager'))+'</div>'
  end
  
end


