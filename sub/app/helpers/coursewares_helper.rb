# -*- encoding : utf-8 -*-
module CoursewaresHelper
  def thank_courseware_ed?(courseware)
    return false if current_user.blank?
    return false if current_user.thanked_courseware_ids.blank?
    return current_user.thanked_courseware_ids.count(courseware.id) > 0
    return
  end
  def page_highlight(html)
    return html_escape(html).gsub('__PSVR_begin_RVSP__','<span class="search-highlight">').gsub('__PSVR_end_RVSP__','</span>').html_safe
  end
end
