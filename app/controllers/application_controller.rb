#   get '/leaders', to: 'application#show_leaders', as: :show_leaders
#   get '/rules', to: 'application#show_rules', as: :show_rules
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  # Get list of top players by score
  # and fetch info about them from vk
  def show_leaders
    @leaders = User.all.order(score: :desc).limit(30)
    app = VK::Application.new app_id: Rails.application.config.vk_app_id, app_secret: Rails.application.config.vk_app_secret
    @leaders_info =  app.users.get user_ids: @leaders.map { |l| l.vk_id.to_s },
                                   fields: ['photo_50'], lang: 'ru'
    # merge @leaders and leaders_info
    @leaders_info.each do |leader|
      leader['score'] = @leaders.select { |l| l.vk_id == leader['uid'] }[0].score
    end
    respond_to do |format|
      format.html { render 'application/show_leaders' }
      format.json { render json: @leaders_info }
    end
  end

  def show_rules
  end
end
