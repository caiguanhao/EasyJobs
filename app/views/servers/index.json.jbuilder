json.array!(@servers) do |server|
  json.extract! server, :name, :host, :username, :password
  json.url server_url(server, format: :json)
end
