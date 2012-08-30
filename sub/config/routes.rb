# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do
  root :to=>'welcome#index'
  get '/api/uc' => 'ucenter#ktv_uc_client'
  post '/api/uc' => 'ucenter#ktv_uc_client'
  get '/favicon'=>'welcome#favicon'

  devise_for :users do
    get "/login", :to => "devise/sessions#new",as:'login'
    get '/logout', :to => "devise/sessions#destroy", as:'logout'
  end
  resources :courses
  resources :teachers
end
