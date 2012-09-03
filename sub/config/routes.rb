# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do
  root :to=>'welcome#index'
  get '/api/uc' => 'ucenter#ktv_uc_client'
  post '/api/uc' => 'ucenter#ktv_uc_client'

  devise_for :users do
    get "/login", :to => "devise/sessions#new",as:'login'
    get '/logout', :to => "devise/sessions#destroy", as:'logout'
  end
  get '/un_courses'=>'courses#index'
  resources :courses
  resources :teachers

  #==
  get '/under_verification' => 'home#under_verification'
  get '/frozen_page' => 'home#frozen_page'

  get '/refresh_sugg' => 'home#refresh_sugg'
  get '/ajax_get_info' => 'home#ajax_get_info'
  get '/refresh_sugg_ex' => 'home#refresh_sugg_ex'  
  post '/ajax/seg'=>'ajax#seg'
  get '/bugtrack'=>'application#bugtrack'
  get '/agreement'=>'home#agreement'
  get "traverse/index",as:'traverse'
  post "traverse/index",as:'traverse'
  get "traverse/asks_from",as:'asks_from'
  get 'home/agreement'

  get 'nb/*file' =>'application#nb'
  get '/for_help' => "home#index"
  get '/root'=>'home#index'
  match '/topics_follow' => 'topics#fol'
  post '/topics_unfollow'=>'topics#unfol'  
  get '/zero_asks' => 'asks#index'

  match "/uploads/*path" => "gridfs#serve"
  match "/update_in_place" => "home#update_in_place"
  #match "/muted" => "home#muted"
  match "/newbie" => "home#newbie"
  match "/followed" => "home#followed"
  match "/recommended" => "home#recommended"
  match "/mark_all_notifies_as_read" => "home#mark_all_notifies_as_read"
  match "/mark_notifies_as_read" => "home#mark_notifies_as_read"

  match "/mute_suggest_item" => "home#mute_suggest_item"
  match "/report" => "home#report"
  #match "/about" => "home#about"
  match "/doing" => "logs#index"

  resources :users do
    member do
      get "answered"
      get "asked"
      get "asked_to"
      get "follow"
      get "unfollow"
      get "followers"
      get "following"
      get "following_topics"
      # get "following_asks"
    end
  end
  match "auth/:provider/callback", :to => "users#auth_callback"  

  resources :search do
    collection do
      get "all"
      get "topics"
      get "asks"
      get "users"
    end
  end

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
    member do
      get "follow"
      get "unfollow"
    end
  end
  resources :logs
    
end
