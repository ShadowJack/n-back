class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
#   get '/play', to: 'application#play', as: :play
#   get '/options', to: 'application#show_options', as: :show_options
#   post '/options', to: 'application#save_options', as: :save_options
#   get '/leaders', to: 'application#show_leaders', as: :show_leaders
#   get '/rules', to: 'application#show_rules', as: :show_rules

  def play
  end
  
  def show_options
  end
  
  def save_options
  end
  
  def show_leaders
  end
  
  def show_rules
  end
   
end
