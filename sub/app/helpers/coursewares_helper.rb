# -*- encoding : utf-8 -*-
module CoursewaresHelper
  def thank_courseware_ed?(courseware)
    return false if current_user.blank?
    return false if current_user.thanked_courseware_ids.blank?
    return current_user.thanked_courseware_ids.count(courseware.id) > 0
    return
  end
end
