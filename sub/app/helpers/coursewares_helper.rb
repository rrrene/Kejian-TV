# -*- encoding : utf-8 -*-
module CoursewaresHelper
  def thank_courseware_ed?(courseware)
    return false if current_user.blank?
    return false if current_user.thanked_courseware_ids.blank?
    return current_user.thanked_courseware_ids.count(courseware.id) > 0
    return
  end
  def page_highlight(html,keyword)
    html=html_escape(html)
    return html.gsub('__PSVR_begin_RVSP__','<span class="search-highlight">').gsub('__PSVR_end_RVSP__','</span>').html_safe
=begin
    chars=keyword.downcase.chars.to_a.uniq
    arr=html.split('__PSVR_begin_RVSP__')
    ret=arr[0]
    arr[1..-1].each do |match__tail|
      rra = match__tail.split('__PSVR_end_RVSP__')
      if (rra[0].downcase.chars.to_a-chars).empty?
        ret += "<span class=\"search-highlight\">#{rra[0]}</span>#{rra[1]}"
      else
        ret += "#{rra[0]}#{rra[1]}"
      end
    end
    highlight(ret,keyword.split(/\s/).compact,:highlighter=>'<span class="search-highlight">\1</span>')
=end
  end
  def gap_days(last,first)
    return ((last-first)/3600/24).to_f
  end
  def percent_days(milestone,first,all)
      gap = ((milestone.getlocal.beginning_of_day.to_i-first)/3600/24).to_f
      return (gap/all*100).to_i
  end
end
