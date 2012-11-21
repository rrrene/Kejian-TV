# -*- encoding : utf-8 -*-
module UsersHelper
  def renzheng_teacher(user)
    if user.is_expert
      "<span class=\"ctf-icon small-ctf-star-w\" title=\"认证老师\"></span>".html_safe
    else
      ''
    end
  end
  def profile_path(user)
    "/users/#{user.id}"
  end
  def user_path(user)
    "/users/#{user.id}"
  end
  def avatar_url_quick(user,size=:normal,reload=false)
    return dz_avatar_url(User.get_uid(user),User.get_email(user),size,reload)
  end
  def name_beautify(name)
    '_'==name.try(:[],0) ? name[1..-1] : name
  end
  def dz_avatar_url(uid,email,size=:normal,reload=false)
    reload = (User.get_avatar_changed_at(uid).to_i > 1.day.ago.to_i)
    if reload
      return "http://uc.#{Setting.ktv_domain}/avatar.php?uid=#{uid}&email=&size=#{size}&psvr_reload=#{Time.now.to_i}"
    else
      return "http://uc.#{Setting.ktv_domain}/avatar.php?uid=#{uid}&email=&size=#{size}"
    end

  end
  def avatar_url(user,size=:normal,reload=false)
    return dz_avatar_url(user.uid,user.email,size,reload)
  end

  def avatar_tag(user,size=:normal,style='',reload=false)
    s=AvatarUploader::DZ_SIZES[size]
    url = avatar_url(user,size,reload)
    ret="<img src=\"#{url}\" class=\"imgHead\" width=\"#{s}\" height=\"#{s}\" alt=\"\" style=\"#{style}\">".html_safe
    return ret
  end
  def user_path2(user)
    "/users/#{user.id}"
  end

  def user_name_tag(user, options = {})
    options[:url] ||= false
    options[:target] ||= ''
    return "" if user.blank?
    # return "匿名用户" if !user.normal_deleting_status
    if !(options[:no_truncate] == true)
      user.name=truncate(user.name,:length => 12, :truncate_string =>"⋯")
    end
    return user.name if user.slug.blank?
    user.slug= user.slug.split('.').join('_')
    url = "/users/#{user.slug}"
    if options[:url] == true
      url = "http://#{Setting.domain}" + url
    end
    raw "<a#{options[:is_notify] == true ? " onclick=\"mark_notifies_as_read(this, '#{options[:notify].id}');\"" : ""} href=\"#{url}\" target=\"#{options[:target]}\" class=\" #{options[:bold] ? 'bold' : ''}\" title=\"#{h(user.name)}\">#{h(user.name)}</a>"
  end

  def user_avatar_tag(user,size,size2=nil,nolink=false)
    # PSVR> this method is expected to have a link 
    return "" if user.blank?
    return "" if user.slug.blank?
    url = eval("user.avatar.#{size}.url")
    if url.blank?
      url = ""
    end
    if user.normal_deleting_status
      if size2
        mid = "<img src=\"#{url}\" class=\"imgHead\" width=\"#{size2}\" height=\"#{size2}\" alt=\"\">"
      else
        mid = "<img src=\"#{url}\" class=\"imgHead\" alt=\"\">"
      end
      if nolink
        raw mid
      else
        raw "<a href=\"#{user_path2(user)}\" class=\"\" title=\"#{h(user.name)}\">#{mid}</a>"
      end
    else
      if size2
        mid="<img src=\"#{url}\" class=\"imgHead\" style=\"'width:'+size2.to_s+'px;height:'+size2.to_s+'px'\" alt=\"user.name\">"
      else
        mid="<img src=\"#{url}\" class=\"imgHead #{size.to_s}\" alt=\"user.name\">"
      end
      if nolink
        raw mid
      else
        raw "<a href=\"#\" class=\"\">"+mid+"</a>"
      end
    end
  end

  def user_avatar_tag2(user,size,ca={},nolink=false)
    ca[:name] ||= User.get_name(user)
    ca[:slug] ||= User.get_slug(user)
    ca[:path] ||= "/users/#{ca[:slug]}"
    
    return "" if user.blank?
    return "" if ca[:slug].blank?
    url = avatar_url_quick(user)
    hash = {class:size.to_s,alt:ca[:name]}
    hash.merge!({width:ca[:size2],height:ca[:size2],class:'imgHead'}) if ca[:size2]
    mid = image_tag(mk_url(url),hash)
    if nolink
      raw mid
    else
      raw "<a href=\"#{ca[:path]}\" class=\"\" title=\"#{ca[:name]}\">"+mid+"</a>"
    end

  end


  def user_tagline_tag(user,options = {})
    return "" if user.blank?
    prefix = options[:prefix] || ""
    return "" if user.tagline.blank?
    raw "#{prefix}#{h(truncate(user.tagline, :length => 30))}"
  end

  def user_sex_title(user,current_user=nil)
    return "" if user.blank?
    return "我" if current_user==user
    "他"
  end

  # 支持者列表
  def up_voter_links(up_voters, options = {})
    # TODO: optimize via redis
    limit = options[:limit] || 3
    links = []
    hide_links = []
    up_voters.each_with_index do |u,i|
      link = user_name_tag(u)
      if i <= limit
        links << link
      else
        hide_links << link
      end
    end
    html = "<span class=\"voters\">#{links.join(",")}"
    if !hide_links.blank?
      html += "<a href=\"#\" onclick=\"$(this).next().show();$(this).replaceWith(',');return false;\" class=\"more\">(更多)</a><span class=\"hide\">#{hide_links.join(",")}</span>"
    end
    html += "</span>"
    raw html
  end
  module_function(*instance_methods)
end
