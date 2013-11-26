# -*- encoding : utf-8 -*-
class DZLinkRenderer<WillPaginate::ActionView::LinkRenderer
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
      link(page, page, :rel => rel_value(page))
    else
      link(page, page, :rel => rel_value(page))
      tag(:strong, page)
    end
  end
    
  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    link(text, '#psvr_dz_pg')
  end
    
  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, @options[:previous_label], 'prev')
  end
    
  def next_page
    num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
    previous_or_next_page(num, @options[:next_label], 'nxt')
  end
    
  def previous_or_next_page(page, text, classname)
    if page
      link(('nxt'==classname ? '下一页' : '&nbsp;&nbsp;'), page, :class => classname)
    else
      ''
    end
  end
    
  def html_container(html)
    '<div class="__dz"><div class="bm bw0 pgs cl" style="margin-bottom:0px" id="psvr_dz_pg"><span id="fd_page_bottom">'+tag(:div, html, container_attributes.merge(:class => 'pg'))+'</span></div></div>'
  end

end
