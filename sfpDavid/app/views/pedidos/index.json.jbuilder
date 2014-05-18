json.array!(@pedidos) do |pedido|
  json.extract! pedido, :id, :Fecha, :Hora, :Rut, :Fecha, :Sku, :CantidadUnidad
  json.url pedido_url(pedido, format: :json)
end
