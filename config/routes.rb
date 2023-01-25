# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  patch :forgot_password, to: 'registrations#forgot_password'
  patch :change_password, to: 'registrations#change_password'
  patch :change_password_with_token, to: 'registrations#change_password_with_token'
  patch :logout, to: 'sessions#destroy'
  get :logged_in, to: 'sessions#logged_in'
  get '/activate_account',
      to: 'registrations#activate_account',
      as: 'activate_account'
  get '/password_reset_account',
      to: 'registrations#password_reset_account',
      as: 'password_reset_account'

  resources :comments, only: %i[show create update destroy]
  resources :posts, only: %i[show create update destroy] do
    member do
      patch :lock_post, to: 'posts#lock_post'
      patch :pin_post, to: 'posts#pin_post'
    end
  end
  resources :forums, only: %i[index create update destroy] do
    collection do
      get '/all', to: 'forums#index_all'
      get '/:forum', to: 'forums#show_by_forum'
      get '/:forum/:subforum', to: 'forums#show_by_subforum'
    end
  end
  resources :subforums, only: %i[create update destroy]

  resources :sign_up, only: %i[create], controller: 'registrations'
  resources :log_in, only: %i[create], controller: 'sessions'
  resources :users, only: %i[index show] do
    member do
      patch :update_image, to: 'users#update_image'
      patch :set_admin_level, to: 'users#set_admin_level'
      patch :suspend_comms, to: 'users#suspend_communication'
    end
  end
end
