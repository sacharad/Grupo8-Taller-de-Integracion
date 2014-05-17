json.array!(@prices) do |price|
  json.extract! price, :id, :type, :price, :update_date, :validity_date, :disposition_expense, :transfer_charge
  json.url price_url(price, format: :json)
end
