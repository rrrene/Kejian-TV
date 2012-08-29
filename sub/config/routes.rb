# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do
  root :to=>'welcome#index'
  get '/api/uc' => 'ucenter#ktv_uc_client'
  post '/api/uc' => 'ucenter#ktv_uc_client'
  get '/favicon'=>'welcome#favicon'

  devise_for :users
  resources :courses
  resources :teachers
end
