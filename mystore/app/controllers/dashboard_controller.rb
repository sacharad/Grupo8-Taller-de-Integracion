class DashboardController < ApplicationController
  def index
  	@quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
  	@pedidos = Order.get_collection("InfoPedidos").count.to_f
  	@ventas = Order.get_collection("Reporte_Ventas").count.to_f
  	@pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f

  end
end
