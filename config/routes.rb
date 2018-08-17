Rails.application.routes.draw do
  resources :articles
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/@:username', to: 'accounts#show', as: :short_account

  resources :accounts, path: 'users', only: [:show], param: :username do
    resources :stream_entries, path: 'updates', only: [:show] do
      member do
        get :embed
      end
    end

    get :remote_follow,  to: 'remote_follow#new'
    post :remote_follow, to: 'remote_follow#create'

    resources :statuses, only: [:show] do
      member do
        get :activity
        get :embed
      end
    end

    resources :followers, only: [:index], controller: :follower_accounts
    resources :following, only: [:index], controller: :following_accounts
    resource :follow, only: [:create], controller: :account_follow
    resource :unfollow, only: [:create], controller: :account_unfollow

    resource :outbox, only: [:show], module: :activitypub
    resource :inbox, only: [:create], module: :activitypub
    resources :collections, only: [:show], module: :activitypub
  end

  resource :inbox, only: [:create], module: :activitypub  

  # Webfinger
  get '.well-known/host-meta', to: 'well_known/host_meta#show', as: :host_meta, defaults: { format: 'xml' }
  get '.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger

  get 'home/index'

  get 'follows/search'
  resources :follows

  root to: 'home#index'
end
