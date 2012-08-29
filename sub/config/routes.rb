# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do
  devise_for :users

  root :to=>'welcome#index'
  get '/favicon'=>'welcome#favicon'
  resources :courses
  resources :teachers
end
