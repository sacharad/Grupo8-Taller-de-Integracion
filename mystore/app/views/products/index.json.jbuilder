json.array!(@products) do |product|
  json.extract! product, :id, :expense, :sku, :image, :description, :brand
  json.url product_url(product, format: :json)
end
