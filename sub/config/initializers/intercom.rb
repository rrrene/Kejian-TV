IntercomRails.config do |config|

  config.app_id = "bbiz3u3s"

  config.api_key = "82d1ccbbccd9305a9fa2f6e8cb0da81757607544"

  config.user.custom_data = {
    :coursewares_uploaded_titles => Proc.new { |current_user| Courseware.where(:uploader_id=>current_user.id).collect{|x| x.title}.join(',') },
    :uid => :uid,
    :reg_extent => :reg_extent,
    :ibeike_uid => :ibeike_uid,
    :ibeike_slug => :ibeike_slug,
    :coursewares_uploaded_count=>:coursewares_uploaded_count,
  }
 
  config.inbox.style = :custom
  config.inbox.counter = true

end
