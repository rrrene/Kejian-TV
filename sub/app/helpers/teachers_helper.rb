# -*- encoding : utf-8 -*-
module TeachersHelper
  def teacher_avatar_url_quick(teacher,size=:normal)
    s=AvatarUploader::SIZES[size]
    url = Teacher.get_avatar_filename(teacher)
    if url.present?
      return url
    else
      url = "/defaults/avatar/#{size}.png"
    end
    return url
  end
  def teacher_avatar_url(teacher,size=:normal)
    s=AvatarUploader::SIZES[size]
    url = teacher.try(:avatar).try(size).try(:url)
    if url.present?
      return url
    else
      url = "/defaults/avatar/#{size}.png"
    end
    return url
  end
  module_function(*instance_methods)
end
