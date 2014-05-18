json.array!(@storehouses) do |storehouse|
  json.extract! storehouse, :id, :capacity, :type
  json.url storehouse_url(storehouse, format: :json)
end
