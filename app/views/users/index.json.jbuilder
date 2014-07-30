json.array!(@users) do |user|
  json.extract! user, :id, :score, :options
  json.url user_url(user, format: :json)
end
