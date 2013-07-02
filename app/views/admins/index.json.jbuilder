json.array!(@admins) do |admin|
  json.extract! admin, :username, :email, :password
  json.url admin_url(admin, format: :json)
end
