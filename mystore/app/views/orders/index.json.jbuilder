json.array!(@orders) do |order|
  json.extract! order, :id, :delivery_date, :order_date
  json.url order_url(order, format: :json)
end
