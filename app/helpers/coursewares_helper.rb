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
    return html.html_safe
  end
  def gap_days(last,first)
    return ((last-first)/3600/24).to_f
  end
  def percent_days(milestone,first,all)
      gap = ((milestone.getlocal.beginning_of_day.to_i-first)/3600/24).to_f
      return (gap/all*100).to_i
  end
  module_function(*instance_methods)
end
