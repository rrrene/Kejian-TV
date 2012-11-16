# -*- encoding : utf-8 -*-
class WendaoLinkRenderer<WillPaginate::ActionView::LinkRenderer
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
      tag(:li, link(tag(:span,page), page, :rel => rel_value(page)))
    else
      tag(:li, link(tag(:span,page, :class => 'current'), page, :rel => rel_value(page)), :class => 'current')
    end
  end
    
  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    %(<li class="more">#{text}</li>)
  end
    
  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, @options[:previous_label], 'previous_page')
  end
    
  def next_page
    num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
    previous_or_next_page(num, @options[:next_label], 'next_page')
  end
    
  def previous_or_next_page(page, text, classname)
    if page
      tag(:li,link(tag(:span,text), page, :class => classname))
    else
      tag(:li,link(tag(:span,text), '', :class => classname+' disabled'))
    end
  end
    
  def html_container(html)
    tag(:section, tag(:ul,html), container_attributes.merge(:class => self.class.sectionPagerKlass))
  end

end

class WendaoLinkCMTRenderer < WendaoLinkRenderer
  @sectionPagerKlass = 'cmtpager clearfix'
  @base_url = nil
end

class WendaoLinkBACKRenderer < WendaoLinkRenderer
  @sectionPagerKlass = 'backpager clearfix'
  @base_url = nil
  
  def to_html  
    html = pagination.map do |item|
      item.is_a?(Fixnum) ?
        page_number(item) :
        send(item)
    end.join(@options[:link_separator])
    html = "<li style='cursor:text;'><span>共#{@collection.total_entries}条</span></li>" + html+"<li style='cursor:text;'><span style='padding-top:2px;border-left:1px solid #cad9ea;'><input type='text' name='page' id='render_page_input' style='margin:0px 5px;' onkeydown='submit_page()'></span></li>"
    @options[:container] ? html_container(html) : html
  end
end

class WendaoLinkRendererASKS < WendaoLinkRenderer
  @sectionPagerKlass = 'pager clearfix'
  @base_url = '/asks'
end

class WendaoLinkRendererZEROASKS < WendaoLinkRenderer
  @sectionPagerKlass = 'pager clearfix'
  @base_url = '/zero_asks'
end
