require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  
  devise_for :users
  
  root to: 'home#index'

  resources :documents, only: [:index, :new, :create, :destroy]
  resources :reports, only: [:index, :show] do
    member do
      get :download
    end
    
    collection do
      post :export
    end
  end
end
