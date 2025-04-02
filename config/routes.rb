Rails.application.routes.draw do
  # root "likes#index"
  root "posts#index"

  get "signup", to: "users#new"
  post "signup", to: "users#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

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
end
