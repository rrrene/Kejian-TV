# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do

  root :to=>'welcome#index'
  get '/api/uc' => 'ucenter#ktv_uc_client'
  post '/api/uc' => 'ucenter#ktv_uc_client'
  get '/user_logged_in_required'=>'application#user_logged_in_required'
  get '/modern_required'=>'application#modern_required'
  
  get '/mine' => 'mine#index'
  get '/mine/dashboard'
  get '/mine/my_coursewares'
  get '/mine/view_all_playlists'
  get '/mine/my_coursewares_copyright'
	get '/mine/my_history'
	get '/mine/my_search_history'
  get '/mine/my_watch_later_coursewares'
  get '/mine/my_favorites'
  get '/mine/my_liked_coursewares'
  get '/mine/my_liked_lists'
  post '/mine/delete' => 'mine#delete'
  get '/mine/:page' => 'mine#index'
  get '/popup/headlines'
  # ________________________________user__________________________________________
  devise_for :users, :path => "account", :controllers => {
      :registrations => :account,
      :confirmations => :account_confirmations,
      :passwords =>  :account_passwords,
      :sessions => :account_sessions,
      :unlocks => :account_unlocks,
      :omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_scope :user do
    # finishing reg process
    put '/account/confirmation' => 'account_confirmations#show'
    get "/register", :to => "account#new",as:'register'
    get "/login", :to => "account_sessions#new",as:'login'
    get "/login_ibeike", :to => "account_sessions#new",as:'login_ibeike'
    get '/logout', :to => "account_sessions#destroy", as:'logout'
    get '/account/edit_pref'
    get '/account/edit_avatar'
    get '/account/edit_profile'
    put '/account/edit_profile' => 'account#update_profile'
    get '/account/edit_slug'
    put '/account/edit_slug' => 'account#update_slug'
    get '/account/edit_notifications'
    get '/account/edit_banking'
    get '/account/edit_passwd'
    get '/account/edit_i18n'
    get '/account/edit_invite'
    get '/account/edit_services'
    get '/account/binds'
    get '/account/bind/:service' => 'account#bind'
    post '/account/bind/:service' => 'account#real_bind'
  end
  match "/account/auth/:provider/unbind", :to => "users#auth_unbind"

  # ________________________________ajax__________________________________________
  get '/all_unread_notification_num' => 'ajax#all_unread_notification_num'
  post '/ajax/renren_huanyizhang'
  post '/ajax/renren_real_bind'
  get '/ajax/check_fangwendizhi'
  get '/ajax/watch_later'
  post '/ajax/seg'=>'ajax#seg'
  post '/presentations' => 'ajax#presentations_upload_finished'
  put '/presentations/:id' => 'ajax#presentations_update'
  get '/presentations/:id/status' => 'ajax#presentations_status'
  get '/ajax/checkUsername'
  get '/ajax/checkEmailAjax'
  get '/ajax/xl_req_get_method_vod'
  post '/ajax/logincheck'
  get '/ajax/star_refresh'
  get '/ajax/get_teachers'
  post '/ajax/get_forum' => 'ajax#get_forum'
  post '/ajax/get_operation' => 'ajax#get_cw_operation'
  post '/ajax/add_to_playlist' => 'ajax#add_to_playlist'
  post '/ajax/playlist_sort' => 'ajax#playlist_sort'
  post '/ajax/create_new_playlist' => 'ajax#create_new_playlist'
  post '/ajax/add_comment_to_playlist' =>'ajax#add_comment_to_playlist'
  post '/ajax/get_share_panel' => 'ajax#get_share_panel'
  post '/ajax/get_share_partial' => 'ajax#get_share_partial'
  post '/ajax/ajax_send_email' =>'ajax#ajax_send_email'
  post '/ajax/flagcw' => 'ajax#flag_cw'
  post '/ajax/get_dynamic_dingcai' => 'ajax#get_dynamic_dingcai'
  post '/ajax/comment_action' => 'ajax#comment_action'
  post '/ajax/get_sorted_playlist' => 'ajax#get_sorted_playlist'
  post '/ajax/add_to_playlist_by_url' => 'ajax#add_to_playlist_by_url'
  post '/ajax/add_to_read_later' => 'ajax#add_to_read_later'
  post '/ajax/get_playlist_share' => 'ajax#get_playlist_share'
  post '/ajax/like_playlist' => 'ajax#like_playlist'
  post '/ajax/get_addto_menu' => 'ajax#get_addto_menu'
  post '/ajax/add_to_read_later_array' =>'ajax#add_to_read_later_array'
  post '/ajax/add_to_playlist_by_id' => 'ajax#add_to_playlist_by_id'
  post '/ajax/create_and_add_to_by_id' => 'ajax#create_and_add_to_by_id'
  post '/ajax/save_note_for_one_cw' => 'ajax#save_note_for_one_cw'
  post '/ajax/add_to_favorites_array' => 'ajax#add_to_favorites_array'
  post '/ajax/remove_ding_array' => 'ajax#remove_ding_array'
  post '/ajax/save_page_to_history' => 'ajax#save_page_to_history'
  post '/ajax/pause_history' => 'ajax#pause_history'
  post '/ajax/remove_one_history' => 'ajax#remove_one_history'
  
  # ---=small=----
  get '/hack/htc'
  get '/welcome/inactive_sign_up'
  get '/welcome/shuffle'
  get '/welcome/blank'
  get '/welcome/surprise' => 'welcome#surprise',:as => 'surprise'
  get '/welcome/top'
  get '/welcome/menu'
  get '/welcome/xi'
  get '/welcome/main'
  get '/welcome/latest'
  get '/welcome/feeds'
  # ________________________________ktv__________________________________________
  resources :play_lists do 
    member do
      post 'handler'
    end
  end
  resources :departments
  resources :courses
  resources :schools
  resources :maps
  get '/un_courses'=>'courses#index'
  get '/coursewares_by_departments' => 'coursewares#index'
  get '/coursewares_by_teachers' => 'coursewares#index'
  get '/coursewares_by_courses' => 'coursewares#index'
  get '/coursewares_with_page' => 'coursewares#index'
  get '/coursewares_with_page/:page' => 'coursewares#index'
  get '/coursewares_mine' => 'coursewares#mine'
  get '/coursewares_mine/:page' => 'coursewares#mine'
  get '/coursewares/:id/revisions/:revision_id' => 'coursewares#show'
  get '/embed/:id/revisions/:revision_id' => 'coursewares#embed'  
  get '/users/test' => 'users#test'
  # resources :notes, :path_prefix => "/coursewares/:id/",
  resources :coursewares do
    resources :notes
    collection do
      get 'mine'
      get 'latest'
      get 'hot'
      get 'videos'
      get 'books'
      get 'new_youku'
      get 'new_emule'
      get 'new_sina'
    end
    member do
      get 'download'
      post 'download'
      get "thank"
    end
  end
  get '/embed/:id' => 'coursewares#embed'

  # ________________________________q-n-a__________________________________________
  get '/home/index',:as=>'home_index'
  match '/mobile'=>'home#mobile'
  get '/under_verification' => 'home#under_verification'
  get '/frozen_page' => 'home#frozen_page'
  
  get '/refresh_sugg' => 'home#refresh_sugg'
  get '/refresh_sugg_ex' => 'home#refresh_sugg_ex'
  
  get '/bugtrack'=>'application#bugtrack'
  get '/agreement'=>'home#agreement'
  get "/traverse/index",as:'traverse'
  post "/traverse/index",as:'traverse'
  get "/traverse/asks_from",as:'asks_from'
  get '/home/agreement'
  
  get '/nb/*file' =>'application#nb'
  get "/home/index",:as => 'for_help'
  get '/root'=>'home#index'
  match '/topics_follow' => 'topics#fol'
  post '/topics_unfollow'=>'topics#unfol'
  get '/zero_asks' => 'asks#index',:as => 'zero_asks'
  
  scope 'mobile',:as=>'mobile' do
    controller "mobile" do
      get 'noticepage'
      get 'login'
      get 'register'
      get 'search'
      get 'notifications'
    end
  end
  
  
  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  #match "/muted" => "home#muted"
  match "/newbie" => "home#newbie",:as => :newbie
  match "/followed" => "home#followed"
  match "/recommended" => "home#recommended"
  match "/mark_all_notifies_as_read" => "home#mark_all_notifies_as_read"
  match "/mark_notifies_as_read" => "home#mark_notifies_as_read"
  
  match "/mute_suggest_item" => "home#mute_suggest_item"
  match "/report" => "home#report"
  #match "/about" => "home#about"
  match "/doing" => "logs#index"
  
  
  resources :teachers do
    member do
      put :action
      post :action
      delete :action
      get "unfollow"
      get "followers"
      get "following"
      get "invites"
      post "follow" => 'users#zm_follow'
      post "unfollow" => 'users#zm_unfollow'
    end
  end  
  resources :users do
    collection do
      get 'hot'
      get 'invite'
      post 'invite_submit'
    end
    member do
      post 'invite_send'
      get "answered"
      get "asked"
      get "asked_to"
      get "follow"
      post "follow" => 'users#zm_follow'
      post "unfollow" => 'users#zm_unfollow'
      get "unfollow"
      get "followers"
      get "following"
      get "invites"
      get "double_follow"
      get "following_topics"
      # get "following_asks"
    end
  end
  get '/autocomplete/all'
  get '/autocomplete/swords'
  get '/search' => 'search#index'
  get '/search/:q' => 'search#show'
  get '/search_contents/:q' => 'search#show_contents'
  get '/search_playlists/:q' => 'search#show_playlists'
  get '/search_courses/:q' => 'search#show_courses'
  get '/search_teachers/:q' => 'search#show_teachers'
  get '/search_users/:q' => 'search#show_users'
  get '/search_lucky/:q' => 'search#lucky'
  
  resources :asks do
    member do
      get "spam"
      get "follow"
      get "unfollow"
      get "mute"
      get "unmute"
      post "answer"
      post "update_topic"
      get "update_topic"
      get "redirect"
      get "invite_to_answer"
      get "share"
      post "share"
    end
  end
  resources :answers do
    member do
      get "vote"
      get "spam"
      get "thank"
    end
  end
  resources :comments
  
  resources :topics do #, :constraints => { :id => /[a-zA-Z\w\s\.%\-_]+/ }
    collection do
      get 'hot'
    end
    member do
      get "follow"
      get "unfollow"
      post 'update_fathers'
      post 'update_title'
    end
  end
  resources :logs do
    collection do
      get 'all'
    end
  end
  resources :inbox
  
  namespace :cpanel do
    get "/flagrecords" => 'flag_record#index'
    post '/toggle' => 'asks#toggle'
    root :to =>  "home#index"
    resources :scopes
    resources :clients do
      put :block, on: :member
      put :unblock, on: :member
    end
    resources :accesses do
      put :block, on: :member
      put :unblock, on: :member
    end
    get '/asks_un' => 'asks#index_un'
  
    get '/asks_un2' => 'asks#index_un2'
    get '/answers_un2' => 'answers#index_un2'
    get '/comments_un2' => 'comments#index_un2'
  
    post '/asks_un2all' => 'asks#index_un2all'
    post '/answers_un2all' => 'answers#index_un2all'
    post '/comments_un2all' => 'comments#index_un2all'
  
    resources :users
    resources :asks do
      post :verify, on: :member
    end
    resources :answers do
      post :verify, on: :member
    end
    resources :topics
    resources :comments do
      post :verify, on: :member
    end
    resources :report_spams
    resources :notices
    get '/oauth' => 'oauth#index',:as=>'oauth'
    get '/stats' => 'stats#index',:as=>'stats'
    match '/kpi' => 'stats#kpi',:as=>'kpi'
    post '/stats/uv' => 'stats#uv'
    match "/stats/hot_asks" => "stats#hot_asks"
    match "/stats/hot_topics" => "stats#hot_topics"
    match "/stats/refresh_asks" => "stats#refresh_asks"
    match "/stats/refresh_topics" => "stats#refresh_topics"
    post '/stats/edit_hot_asks' => 'stats#edit_hot_asks'
    post '/stats/edit_hot_topics' => 'stats#edit_hot_topics'
    get '/autofollow' => 'autofollow#index',:as=>'autofollow'
    post '/autofollow' => 'autofollow#index_pos',:as=>'autofollow_pos'
    delete '/autofollow' => 'autofollow#index_del',:as=>'autofollow_del'
    match '/autofollow/verify' => 'autofollow#verify'
    match '/autofollow/advertise' => 'autofollow#advertise'
    match '/autofollow/ban_word' => 'autofollow#ban_word'
    match '/autofollow/deleted' => 'autofollow#deleted'
    post '/deal_asks' => 'asks#deal_asks'
    post '/deal_answers' => 'answers#deal_answers'
    post '/deal_comments' => 'comments#deal_comments'
    post '/deal_topics' => 'topics#deal_topics'
    post '/deal_report' => 'report_spams#deal_report'
    post '/deal_verify' => 'autofollow#deal_verify'
    post '/deal_advertise' => 'autofollow#deal_advertise'
    post '/deal_word' => 'autofollow#deal_word'
    post '/deal_deleted' => 'autofollow#deal_deleted'
    post '/autofollow/edit_verify' => 'autofollow#edit_verify'
    post '/autofollow/edit_ask_advertise' => 'autofollow#edit_ask_advertise'
    post '/autofollow/edit_ac_advertise' => 'autofollow#edit_ac_advertise'
    post '/autofollow/create_ban_word' => 'autofollow#create_ban_word'
    post '/autofollow/import_ban_word' => 'autofollow#import_ban_word'
    match "/welcome" => "users#welcome"
    match "/user/avatar_admin"=>"users#avatar_admin"
    match "/user/avatar_del"=>"users#avatar_del"
    match "/users/:id/edit_admin" => "users#edit_admin"
    match "/users/:id/update_admin" => "users#update_admin"
    match "/notices/create" => "notices#create"
  end
  
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.super_admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  get "/:id" => "users#show"
  get "/:id/redirect_to/:service" => "users#redirect_to_service"
end
