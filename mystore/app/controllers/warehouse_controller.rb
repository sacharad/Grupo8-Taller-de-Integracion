class WarehouseController < ApplicationController
  def index()
    conn = Connectors::WarehouseConnector.new
    @almacenes = conn.getAlmacenes()

  end
  def almacen()
    @almacen_id = params[:almacen_id]
    conn = Connectors::WarehouseConnector.new
    @skus = conn.getSkusWithStock(@almacen_id)

  end
  def sku()
    @almacen_id = params[:almacen_id]
    @sku_id = params[:sku_id]
    conn = Connectors::WarehouseConnector.new
    @sku_info = conn.getStock(@almacen_id, @sku_id)
  end
end
