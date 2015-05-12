BreadExpress::Application.routes.draw do
  # Routes for main resources
  resources :addresses
  resources :customers
  resources :orders
  resources :users
  resources :sessions
  resources :items
  resources :item_prices

  # Authentication routes
  get 'user/edit' => 'users#edit', as: :edit_current_user
  get 'signup' => 'customers#new', as: :signup
  get 'logout' => 'sessions#destroy', as: :logout
  get 'login' => 'sessions#new', as: :login

  # Semi-static page routes
  get 'home' => 'home#home', as: :home
  get 'about' => 'home#about', as: :about
  get 'contact' => 'home#contact', as: :contact
  get 'privacy' => 'home#privacy', as: :privacy
  get 'search' => 'home#search', as: :search
  get 'cylon' => 'errors#cylon', as: :cylon
  
  # Set the root url
  root :to => 'home#home'  
  
  # Named routes
  get 'cart' => 'home#cart', as: :cart
  get 'add_item/:id' => 'sessions#add_item', :as => :add_item
  get 'remove_item/:id' => 'sessions#remove_item', :as => :remove_item
  get 'remove_one_of_item/:id' => 'sessions#remove_one_of_item', :as => :remove_one_of_item

  # Last route in routes.rb that essentially handles routing errors
  get '*a', to: 'errors#routing'
end
