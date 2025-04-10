Rails.application.routes.draw do
  devise_for :users

  root "posts#index"

  resources :posts do
    resources :comments, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
  end

  resources :users, only: [:show] do
    member do
      post :follow
      delete :unfollow
    end
  end

  resources :profiles, only: [:show, :edit, :update]

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "signup", to: "registrations#create"
        post 'login', to: 'sessions#create'
        # post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
      end

      resources :posts, only: [:index, :show, :create, :destroy]
    end
  end




end
