Rails.application.routes.draw do
  resources :articles
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/@:username', to: 'accounts#show', as: :short_account
  resources :accounts

  # Webfinger
  get '.well-known/host-meta', to: 'well_known/host_meta#show', as: :host_meta, defaults: { format: 'xml' }
  get '.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger

  get 'home/index'

  get 'follows/search'
  resources :follows

  root to: 'home#index'
end
