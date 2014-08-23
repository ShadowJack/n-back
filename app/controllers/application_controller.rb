class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  
#   get '/play', to: 'application#play', as: :play
#   get '/options', to: 'application#show_options', as: :show_options
#   post '/options', to: 'application#save_options', as: :save_options
#   get '/leaders', to: 'application#show_leaders', as: :show_leaders
#   get '/rules', to: 'application#show_rules', as: :show_rules
  
  def show_leaders
    @leaders = User.all.order(score: :desc).limit(30)
    logger.debug "Leaders: " + @leaders.inspect
    app = VK::Application.new app_id: 4485055, app_secret: 'bTODEWKsNb6ICU1CcrJZ'
    @leaders_info =  app.users.get user_ids: @leaders.map{|l| l.vk_id.to_s}, fields: ["photo_50"], lang: "ru"
    logger.debug "Leaders: " + @leaders_info.to_s
    # merge @leaders and leaders_info
    @leaders_info.each do |leader|
      leader["score"] = @leaders.select {|l| l.vk_id == leader["uid"]}[0].score
    end
    respond_to do |format|
      format.html {render 'application/show_leaders'}
      format.json {render json: @leaders_info}
    end
  end
  
  def show_rules
  end
  
end
