json.array!(@clients) do |client|
  json.extract! client, :id, :phone_number, :first_name, :last_name, :code, :dispatch_address
  json.url client_url(client, format: :json)
end
