# -*- encoding : utf-8 -*-
module TeachersHelper
  def teacher_avatar_url_quick(teacher,size=:normal)
    s=AvatarUploader::SIZES[size]
    url = Teacher.get_avatar_filename(teacher)
    if url.blank?
      url = "/defaults/avatar/#{size}.png"
    elsif url.starts_with?('http://')
      d = CGI::escape("/defaults/avatar/#{size}.png")
      url = "#{url}?r=PG&s=#{s}&d=#{d}"
    else
      url = "#{Setting.upload_url}/teacher/avatar/#{teacher}/#{size}_#{url}"
    end
  end
end
