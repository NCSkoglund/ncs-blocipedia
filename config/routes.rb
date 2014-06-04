NcsBlocipedia::Application.routes.draw do
  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users, only: [:index, :show]
  resources :wikis
  resources :tags, only: [:index, :show]
end