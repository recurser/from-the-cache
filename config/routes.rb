CacheProxy::Application.routes.draw do

    resources :contacts, :only => [:new, :create]
    resources  :users
    devise_for :users, :path => '/account'

    match '/contact',         :to => 'contacts#new'
  
    match '/about',           :to => 'pages#about'
  
    root :to => 'pages#home'
  
end
