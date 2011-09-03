Fratpage::Application.routes.draw do

  resources :photos
  resources :albums
  resources :events
  resources :wiki_pages
  resources :members do
    put :make_phi, :on => :member
  end
  resources :sessions

  #map.login "/login", :controller => "sessions", :action => "new"
  match "/login" => "sessions#new", :as => :login
  #map.logout "/logout", :controller => "sessions", :action => "destroy"
  match "/logout" => "sessions#destroy", :as => :logout
  
  #map.connect 'events/:year/:month/:day', :controller => "events", :action => "index"
  match 'events/:year/:month/:day' => "events#index"

  root :controller => "main_areas", :action => "index"

  match ":action", :controller => "main_areas"
end
