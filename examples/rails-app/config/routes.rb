ActionController::Routing::Routes.draw do |map|

  map.resource :session, :only => [:new, :create, :destroy]
  map.login  '/login',  :controller => :sessions, :action => :new
  map.logout '/logout', :controller => :sessions, :action => :destroy

  map.resources :home, :only => [:index]
  map.resources :blocked, :only => [:index]

  map.root :controller => :home
end
