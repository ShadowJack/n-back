#   get '/leaders', to: 'application#show_leaders', as: :show_leaders
#   get '/rules', to: 'application#show_rules', as: :show_rules
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, only: Proc.new { |c| c.request.format.json? }

  # Get list of top players by score
  # and fetch info about them from vk
  def show_leaders
    @leaders = User.all.order(score: :desc).limit(30)

    result = HTTParty.get("https://api.vk.com/method/users.get", query: {
      user_ids: @leaders.map { |l| l.vk_id }.join(","),
      fields: 'photo_50',
      access_token: Rails.application.config.vk[:access_token],
      v: '5.103',
      lang: 'ru'
    }, logger: Rails.logger, log_level: :debug, log_format: :curl)

    response = JSON.parse(result.body)
    logger.info(response)

    @leaders_info = response['response']
    logger.info(@leaders_info)

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
