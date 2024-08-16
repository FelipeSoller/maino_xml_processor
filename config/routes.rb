require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  
  devise_for :users
  
  root to: 'home#index'

  resources :documents, only: [:index, :new, :create, :destroy]
  resources :reports, only: [:index, :show] do
    collection do
      post :export_documents
    end
  end
end
