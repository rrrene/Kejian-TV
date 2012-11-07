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
    url = item.try(:avatar).try(size).try(:url)
    if url.present?
      return url
    else
      url = "/defaults/avatar/#{size}.png"
    end
    return url
  end
end
