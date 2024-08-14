require 'sidekiq/web'

Rails.application.routes.draw do
  get 'reports/index'
  get 'reports/show'
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  
  devise_for :users
  
  root to: 'home#index'

  resources :documents, only: [:index, :new, :create]
  resources :reports, only: [:index, :show]
end
