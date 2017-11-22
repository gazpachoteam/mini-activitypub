Rails.application.routes.draw do
  resources :articles
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get 'home/index'

  get 'follows/search'
  resources :follows

  root to: 'home#index'
end
