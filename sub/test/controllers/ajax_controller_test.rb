# -*- encoding : utf-8 -*-
require "test_helper"
describe AjaxController do
  before do
    @user=User.nondeleted.normal.where(:email.nin=>Setting.admin_emails).first
  end

  it '有没有新通知all_unread_notification_num - 游客状态' do    
    assert @controller.current_user.nil?
      get 'all_unread_notification_num'
    assert 401==@response.status,'没登陆的用户没啥通知可获取的，401禁止使用此操作'
  end
  it '有没有新通知all_unread_notification_num' do    
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'all_unread_notification_num'
    assert @response.success?,'登录了的用户可以获得现在有没有新通知'
  end
 

  it "目前的注册程度current_user_reg_extent - 游客状态" do
    assert @controller.current_user.nil?
      get 'current_user_reg_extent'
    assert @response.success?,'游客可以取得它的目前的注册程度，用于第一次注册时的进度条'
  end
  it "目前的注册程度current_user_reg_extent" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'current_user_reg_extent'
    assert @response.success?,'登录用户可以取得它的目前的注册程度，用于第一次注册时的进度条'
  end
    

  # it "check_fangwendizhi - 游客状态" do
  #   assert @controller.current_user.nil?
  #     get 'check_fangwendizhi'
  #   assert 401==@response.status,'游客不能check_fangwendizhi'
  # end
  # it "check_fangwendizhi" do
  #   denglu! @user
  #   assert @controller.current_user.id==@user.id
  #     get 'check_fangwendizhi'
  #   assert @response.success?,'登录用户可以check_fangwendizhi'
  # end
  #   

  it "watch_later - 游客状态" do
    assert @controller.current_user.nil?
      get 'watch_later'
    assert 401==@response.status,'游客不能watch_later'
  end
  it "watch_later" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'watch_later'
    assert @response.success?,'登录用户可以watch_later'
  end
    

  it "seg - 游客状态" do
    assert @controller.current_user.nil?
      post 'seg'
    assert @response.success?,'游客可以'
  end
  it "seg" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'seg'
    assert @response.success?,'登录用户可以seg'
  end
    

  it "presentations_upload_finished - 游客状态" do
    assert @controller.current_user.nil?
      post 'presentations_upload_finished'
    assert 401==@response.status,'游客不能presentations_upload_finished'
  end
  it "presentations_upload_finished" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'presentations_upload_finished'
    assert @response.success?,'登录用户可以presentations_upload_finished'
  end
    

  it "presentations_update - 游客状态" do
    assert @controller.current_user.nil?
      put 'presentations_update'
    assert 401==@response.status,'游客不能presentations_update'
  end
  it "presentations_update" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      put 'presentations_update'
    assert @response.success?,'登录用户可以presentations_update'
  end
    

  it "presentations_status - 游客状态" do
    assert @controller.current_user.nil?
      get 'presentations_status'
    assert 401==@response.status,'游客不能presentations_status'
  end
  it "presentations_status" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'presentations_status'
    assert @response.success?,'登录用户可以presentations_status'
  end
    

  it "checkUsername - 游客状态" do
    assert @controller.current_user.nil?
      get 'checkUsername'
    assert @response.success?,'游客可以'
  end
  it "checkUsername" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'checkUsername'
    assert @response.success?,'登录用户可以checkUsername'
  end
    

  it "checkEmailAjax - 游客状态" do
    assert @controller.current_user.nil?
      get 'checkEmailAjax'
    assert @response.success?,'游客可以'
  end
  it "checkEmailAjax" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'checkEmailAjax'
    assert @response.success?,'登录用户可以checkEmailAjax'
  end
    

  it "xl_req_get_method_vod - 游客状态" do
    assert @controller.current_user.nil?
      get 'xl_req_get_method_vod'
    assert @response.success?,'游客可以'
  end
  it "xl_req_get_method_vod" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'xl_req_get_method_vod'
    assert @response.success?,'登录用户可以xl_req_get_method_vod'
  end
    

  it "logincheck - 游客状态" do
    assert @controller.current_user.nil?
      post 'logincheck'
    assert @response.success?,'游客可以'
  end
  it "logincheck" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'logincheck'
    assert @response.success?,'登录用户可以logincheck'
  end
    

  it "star_refresh - 游客状态" do
    assert @controller.current_user.nil?
      get 'star_refresh'
    assert @response.success?,'游客可以'
  end
  it "star_refresh" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'star_refresh'
    assert @response.success?,'登录用户可以star_refresh'
  end
    

  it "get_teachers - 游客状态" do
    assert @controller.current_user.nil?
      get 'get_teachers'
    assert 401==@response.status,'游客不能get_teachers'
  end
  it "get_teachers" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      get 'get_teachers'
    assert @response.success?,'登录用户可以get_teachers'
  end
    

  it "get_forum - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_forum'
    assert 401==@response.status,'游客不能get_forum'
  end
  it "get_forum" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_forum'
    assert @response.success?,'登录用户可以get_forum'
  end
    

  it "get_cw_operation - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_cw_operation'
    assert 401==@response.status,'游客不能get_cw_operation'
  end
  it "get_cw_operation" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_cw_operation'
    assert @response.success?,'登录用户可以get_cw_operation'
  end
    

  it "add_to_playlist - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_playlist'
    assert 401==@response.status,'游客不能add_to_playlist'
  end
  it "add_to_playlist" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_playlist'
    assert @response.success?,'登录用户可以add_to_playlist'
  end
    

  it "playlist_sort - 游客状态" do
    assert @controller.current_user.nil?
      post 'playlist_sort'
    assert 401==@response.status,'游客不能playlist_sort'
  end
  it "playlist_sort" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'playlist_sort'
    assert @response.success?,'登录用户可以playlist_sort'
  end
    

  it "create_new_playlist - 游客状态" do
    assert @controller.current_user.nil?
      post 'create_new_playlist'
    assert 401==@response.status,'游客不能create_new_playlist'
  end
  it "create_new_playlist" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'create_new_playlist'
    assert @response.success?,'登录用户可以create_new_playlist'
  end
    

  it "get_share_panel - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_share_panel'
    assert 401==@response.status,'游客不能get_share_panel'
  end
  it "get_share_panel" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_share_panel'
    assert @response.success?,'登录用户可以get_share_panel'
  end
    

  it "get_share_partial - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_share_partial'
    assert 401==@response.status,'游客不能get_share_partial'
  end
  it "get_share_partial" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_share_partial'
    assert @response.success?,'登录用户可以get_share_partial'
  end
    

  it "ajax_send_email - 游客状态" do
    assert @controller.current_user.nil?
      post 'ajax_send_email'
    assert 401==@response.status,'游客不能ajax_send_email'
  end
  it "ajax_send_email" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'ajax_send_email'
    assert @response.success?,'登录用户可以ajax_send_email'
  end
    

  it "flag_cw - 游客状态" do
    assert @controller.current_user.nil?
      post 'flag_cw'
    assert 401==@response.status,'游客不能flag_cw'
  end
  it "flag_cw" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'flag_cw'
    assert @response.success?,'登录用户可以flag_cw'
  end
    

  it "get_dynamic_dingcai - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_dynamic_dingcai'
    assert 401==@response.status,'游客不能get_dynamic_dingcai'
  end
  it "get_dynamic_dingcai" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_dynamic_dingcai'
    assert @response.success?,'登录用户可以get_dynamic_dingcai'
  end
    

  it "comment_action - 游客状态" do
    assert @controller.current_user.nil?
      post 'comment_action'
    assert 401==@response.status,'游客不能comment_action'
  end
  it "comment_action" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'comment_action'
    assert @response.success?,'登录用户可以comment_action'
  end
    

  it "get_sorted_playlist - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_sorted_playlist'
    assert 401==@response.status,'游客不能get_sorted_playlist'
  end
  it "get_sorted_playlist" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_sorted_playlist'
    assert @response.success?,'登录用户可以get_sorted_playlist'
  end
    

  it "add_to_playlist_by_url - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_playlist_by_url'
    assert 401==@response.status,'游客不能add_to_playlist_by_url'
  end
  it "add_to_playlist_by_url" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_playlist_by_url'
    assert @response.success?,'登录用户可以add_to_playlist_by_url'
  end
    

  it "add_to_read_later - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_read_later'
    assert 401==@response.status,'游客不能add_to_read_later'
  end
  it "add_to_read_later" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_read_later'
    assert @response.success?,'登录用户可以add_to_read_later'
  end
    

  it "get_playlist_share - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_playlist_share'
    assert 401==@response.status,'游客不能get_playlist_share'
  end
  it "get_playlist_share" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_playlist_share'
    assert @response.success?,'登录用户可以get_playlist_share'
  end
    

  it "like_playlist - 游客状态" do
    assert @controller.current_user.nil?
      post 'like_playlist'
    assert 401==@response.status,'游客不能like_playlist'
  end
  it "like_playlist" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'like_playlist'
    assert @response.success?,'登录用户可以like_playlist'
  end
    

  it "get_addto_menu - 游客状态" do
    assert @controller.current_user.nil?
      post 'get_addto_menu'
    assert 401==@response.status,'游客不能get_addto_menu'
  end
  it "get_addto_menu" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'get_addto_menu'
    assert @response.success?,'登录用户可以get_addto_menu'
  end
    

  it "add_to_read_later_array - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_read_later_array'
    assert 401==@response.status,'游客不能add_to_read_later_array'
  end
  it "add_to_read_later_array" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_read_later_array'
    assert @response.success?,'登录用户可以add_to_read_later_array'
  end
    

  it "add_to_playlist_by_id - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_playlist_by_id'
    assert 401==@response.status,'游客不能add_to_playlist_by_id'
  end
  it "add_to_playlist_by_id" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_playlist_by_id'
    assert @response.success?,'登录用户可以add_to_playlist_by_id'
  end
    

  it "create_and_add_to_by_id - 游客状态" do
    assert @controller.current_user.nil?
      post 'create_and_add_to_by_id'
    assert 401==@response.status,'游客不能create_and_add_to_by_id'
  end
  it "create_and_add_to_by_id" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'create_and_add_to_by_id'
    assert @response.success?,'登录用户可以create_and_add_to_by_id'
  end
    

  it "save_note_for_one_cw - 游客状态" do
    assert @controller.current_user.nil?
      post 'save_note_for_one_cw'
    assert 401==@response.status,'游客不能save_note_for_one_cw'
  end
  it "save_note_for_one_cw" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'save_note_for_one_cw'
    assert @response.success?,'登录用户可以save_note_for_one_cw'
  end
    

  it "add_to_favorites_array - 游客状态" do
    assert @controller.current_user.nil?
      post 'add_to_favorites_array'
    assert 401==@response.status,'游客不能add_to_favorites_array'
  end
  it "add_to_favorites_array" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'add_to_favorites_array'
    assert @response.success?,'登录用户可以add_to_favorites_array'
  end
    

  it "remove_ding_array - 游客状态" do
    assert @controller.current_user.nil?
      post 'remove_ding_array'
    assert 401==@response.status,'游客不能remove_ding_array'
  end
  it "remove_ding_array" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'remove_ding_array'
    assert @response.success?,'登录用户可以remove_ding_array'
  end
    

  it "save_page_to_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'save_page_to_history'
    assert 401==@response.status,'游客不能save_page_to_history'
  end
  it "save_page_to_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'save_page_to_history'
    assert @response.success?,'登录用户可以save_page_to_history'
  end
    

  it "pause_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'pause_history'
    assert 401==@response.status,'游客不能pause_history'
  end
  it "pause_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'pause_history'
    assert @response.success?,'登录用户可以pause_history'
  end
    

  it "remove_one_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'remove_one_history'
    assert 401==@response.status,'游客不能remove_one_history'
  end
  it "remove_one_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'remove_one_history'
    assert @response.success?,'登录用户可以remove_one_history'
  end
    

  it "clear_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'clear_history'
    assert 401==@response.status,'游客不能clear_history'
  end
  it "clear_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'clear_history'
    assert @response.success?,'登录用户可以clear_history'
  end
    

  it "remove_one_search_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'remove_one_search_history'
    assert 401==@response.status,'游客不能remove_one_search_history'
  end
  it "remove_one_search_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'remove_one_search_history'
    assert @response.success?,'登录用户可以remove_one_search_history'
  end
    

  it "pause_search_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'pause_search_history'
    assert 401==@response.status,'游客不能pause_search_history'
  end
  it "pause_search_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'pause_search_history'
    assert @response.success?,'登录用户可以pause_search_history'
  end
    

  it "clear_search_history - 游客状态" do
    assert @controller.current_user.nil?
      post 'clear_search_history'
    assert 401==@response.status,'游客不能clear_search_history'
  end
  it "clear_search_history" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'clear_search_history'
    assert @response.success?,'登录用户可以clear_search_history'
  end
    

  it "delete_upload - 游客状态" do
    assert @controller.current_user.nil?
      post 'delete_upload'
    assert 401==@response.status,'游客不能delete_upload'
  end
  it "delete_upload" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'delete_upload'
    assert @response.success?,'登录用户可以delete_upload'
  end
    

  it "setting_cw_license - 游客状态" do
    assert @controller.current_user.nil?
      post 'setting_cw_license'
    assert 401==@response.status,'游客不能setting_cw_license'
  end
  it "setting_cw_license" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'setting_cw_license'
    assert @response.success?,'登录用户可以setting_cw_license'
  end
    

  it "enable_beauty_view - 游客状态" do
    assert @controller.current_user.nil?
      post 'enable_beauty_view'
    assert 401==@response.status,'游客不能enable_beauty_view'
  end
  it "enable_beauty_view" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'enable_beauty_view'
    assert @response.success?,'登录用户可以enable_beauty_view'
  end
    

  it "set_privacy - 游客状态" do
    assert @controller.current_user.nil?
      post 'set_privacy'
    assert 401==@response.status,'游客不能set_privacy'
  end
  it "set_privacy" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'set_privacy'
    assert @response.success?,'登录用户可以set_privacy'
  end
    

  it "update_widget_sort - 游客状态" do
    assert @controller.current_user.nil?
      post 'update_widget_sort'
    assert 401==@response.status,'游客不能update_widget_sort'
  end
  it "update_widget_sort" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'update_widget_sort'
    assert @response.success?,'登录用户可以update_widget_sort'
  end
    

  it "request_widget - 游客状态" do
    assert @controller.current_user.nil?
      post 'request_widget'
    assert 401==@response.status,'游客不能request_widget'
  end
  it "request_widget" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'request_widget'
    assert @response.success?,'登录用户可以request_widget'
  end
    

  it "update_widget_property - 游客状态" do
    assert @controller.current_user.nil?
      post 'update_widget_property'
    assert 401==@response.status,'游客不能update_widget_property'
  end
  it "update_widget_property" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'update_widget_property'
    assert @response.success?,'登录用户可以update_widget_property'
  end
    

  it "bar_update_content_in_playlist - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_update_content_in_playlist'
    assert 401==@response.status,'游客不能bar_update_content_in_playlist'
  end
  it "bar_update_content_in_playlist" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_update_content_in_playlist'
    assert @response.success?,'登录用户可以bar_update_content_in_playlist'
  end
    

  it "bar_request_save_as - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_request_save_as'
    assert 401==@response.status,'游客不能bar_request_save_as'
  end
  it "bar_request_save_as" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_request_save_as'
    assert @response.success?,'登录用户可以bar_request_save_as'
  end
    

  it "bar_playlist_save_as - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_playlist_save_as'
    assert 401==@response.status,'游客不能bar_playlist_save_as'
  end
  it "bar_playlist_save_as" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_playlist_save_as'
    assert @response.success?,'登录用户可以bar_playlist_save_as'
  end
    

  it "bar_request_update_bar - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_request_update_bar'
    assert 401==@response.status,'游客不能bar_request_update_bar'
  end
  it "bar_request_update_bar" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_request_update_bar'
    assert @response.success?,'登录用户可以bar_request_update_bar'
  end
    

  it "bar_delete_one_content - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_delete_one_content'
    assert 401==@response.status,'游客不能bar_delete_one_content'
  end
  it "bar_delete_one_content" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_delete_one_content'
    assert @response.success?,'登录用户可以bar_delete_one_content'
  end
    

  it "bar_undo_delete - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_undo_delete'
    assert 401==@response.status,'游客不能bar_undo_delete'
  end
  it "bar_undo_delete" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_undo_delete'
    assert @response.success?,'登录用户可以bar_undo_delete'
  end
    

  it "bar_request_playlists - 游客状态" do
    assert @controller.current_user.nil?
      post 'bar_request_playlists'
    assert 401==@response.status,'游客不能bar_request_playlists'
  end
  it "bar_request_playlists" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'bar_request_playlists'
    assert @response.success?,'登录用户可以bar_request_playlists'
  end
    

  it "summonQL - 游客状态" do
    assert @controller.current_user.nil?
      post 'summonQL'
    assert 401==@response.status,'游客不能summonQL'
  end
  it "summonQL" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'summonQL'
    assert @response.success?,'登录用户可以summonQL'
  end
    

  it "prepare_upload - 游客状态" do
    assert @controller.current_user.nil?
      post 'prepare_upload'
    assert 401==@response.status,'游客不能prepare_upload'
  end
  it "prepare_upload" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'prepare_upload'
    assert @response.success?,'登录用户可以prepare_upload'
  end
    

  it "upload_page_auto_save - 游客状态" do
    assert @controller.current_user.nil?
      post 'upload_page_auto_save'
    assert 401==@response.status,'游客不能upload_page_auto_save'
  end
  it "upload_page_auto_save" do
    denglu! @user
    assert @controller.current_user.id==@user.id
      post 'upload_page_auto_save'
    assert @response.success?,'登录用户可以upload_page_auto_save'
  end
    

end