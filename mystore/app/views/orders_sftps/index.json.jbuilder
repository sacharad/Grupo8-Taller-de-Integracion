json.array!(@orders_sftps) do |orders_sftp|
  json.extract! orders_sftp, :id, :name
  json.url orders_sftp_url(orders_sftp, format: :json)
end
