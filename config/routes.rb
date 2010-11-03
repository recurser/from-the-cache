FromTheCache::Application.routes.draw do

    resources :contacts, :only => [:new, :create]

    match '/contact', :to => 'contacts#new'
  
    match '/about',   :to => 'pages#about'
  
    root              :to => 'pages#search'
    
    # Handle bistro_car javascript for development - the catch-all at the end breaks this.
    match '/javascripts/bundle/:bundle.js', :to => 'bistro_car/bundle#show'
    
    # Send any unknown controller/actions to the search page.
    match '*catch_all', :to => 'pages#search'
  
end
