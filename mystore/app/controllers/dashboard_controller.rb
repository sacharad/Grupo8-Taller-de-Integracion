class DashboardController < ApplicationController
  respond_to :html, :json
  layout "dashboard"

  def index
  	@quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
  	@pedidos = Order.get_collection("InfoPedidos").count.to_f
  	@ventas = Order.get_collection("Reporte_Ventas").count.to_f
  	@pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f

  end

  def show_sales

  	 @list_hash = Order.get_report("Reporte_Ventas") 
	 	
  end

  def show_brokestock

	   @list_hash = Order.get_report("Reporte_QuiebresStock")

  end

  def show_wrongorders

  	 @list_hash = Order.get_report("Reporte_OrdenesIncorrectas") 
  	  	
  end
  def week
    @quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
    @pedidos = Order.get_collection("InfoPedidos").count.to_f
    @ventas = Order.get_collection("Reporte_Ventas").count.to_f
    @pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f
    render 'week'
  end
 

end
