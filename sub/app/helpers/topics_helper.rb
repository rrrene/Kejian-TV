module TopicsHelper
  def cover_url(user,size=:normal)
    s=AvatarUploader::SIZES[size]
    url = eval("user.cover.#{size}.url")
    if user.cover.blank? or url.blank?
      url = "/defaults/cover/#{size}.gif"
    end
    return url
  end

  def topic_name_tag(topic, options = {})
    limit = options[:limit] || 10
    prefix = options[:prefix] || ''
    raw "<a href='#{topic_path(topic.name)}' title='#{h(topic.name)}'>#{prefix}#{h(topic.name)}</a>"
  end

  def topic_cover_tag(topic, size, options = {})
    limit = options[:limit] || 10
      url = eval("topic.cover.#{size}.url")
    raw "<a href='#{topic_path(topic.name)}' title='#{h(topic.name)}'>#{image_tag(url, :class => size.to_s+' imgHead', width:options[:size2], height:options[:size2])}</a>"
  end
  
  def topic_avatar(topic_id)
    "#{Setting.upload_url}/topic/cover/#{topic_id}/small38_______.jpg" 
  end
end