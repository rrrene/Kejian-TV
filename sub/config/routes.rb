# -*- encoding : utf-8 -*-
Sub::Application.routes.draw do
  root :to=>'welcome#index'
  get '/favicon'=>'welcome#favicon'
  resources :courses
end
