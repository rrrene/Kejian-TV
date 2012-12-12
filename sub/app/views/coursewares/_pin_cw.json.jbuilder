json.avatarTiny avatar_url_quick(courseware.uploader_id,:small)
json.selectedBoardIds []
json.boardId courseware.course_fid
json.isSurprise false
json.sharePicId 159510
json.shareTitle "#{courseware.title}#{'2'==params['queryOrder'] ? ' ('+courseware.views_count.to_s+'点击)' : ''}"
json.commentCount 0
json.reshareCount 0
json.id courseware.id
json.ktvid courseware.ktvid
json.path courseware_path(courseware)
json.title courseware.title
json.boardPicId 825398
json.price courseware.title
json.isOriginal true
json.nickName name_beautify User.get_name(courseware.uploader_id)
json.userId User.get_slug(courseware.uploader_id)
json.avatars Hash[]
json.certifyType 2
json.boardName Course.get_name(courseware.course_fid)
json.comments []
json.boardUserId 251621
json.mediumZoom asset_url(courseware.pinpic)
json.timeAgo timeago(courseware.created_at)
