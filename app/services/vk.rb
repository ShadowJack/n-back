require Logger
require HTTParty

class Vk

  @@configs = Rails.application.config.vk

  # Retrieve user details by the list of user ids
  def self.get_users(user_ids)
    response = HTTParty.get("https://api.vk.com/method/users.get", query: {
      "user_ids" => user_ids.join(","), 
      "fields" => "photo_50", 
      "access_token" => @@configs.access_token, 
      "v" => @@config.api_version, 
      "lang" => "ru"
    })

    if response.code >= 200 || response.code < 300 then
      logger.info(response.body)
      return []
    else
      logger.error("Failed request to VK. Code: #{response.code}")
      return []
    end
  end
end
