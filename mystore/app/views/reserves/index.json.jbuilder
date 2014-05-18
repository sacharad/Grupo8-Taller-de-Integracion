json.array!(@reserves) do |reserf|
  json.extract! reserf, :id, :unit, :amount, :date
  json.url reserf_url(reserf, format: :json)
end
