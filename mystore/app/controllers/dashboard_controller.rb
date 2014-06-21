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
  def total
    @quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
    @pedidos = Order.get_collection("InfoPedidos").count.to_f
    @ventas = Order.get_collection("Reporte_Ventas").count.to_f
    @pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f
    render 'total'
  end
  def year
    @quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
    @pedidos = Order.get_collection("InfoPedidos").count.to_f
    @ventas = Order.get_collection("Reporte_Ventas").count.to_f
    @pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f
    render 'year'
  end
  def month
    @quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
    @pedidos = Order.get_collection("InfoPedidos").count.to_f
    @ventas = Order.get_collection("Reporte_Ventas").count.to_f
    @pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f
    render 'month'
  end
  def week
    @quiebres = ActiveSupport::JSON.decode(Order.split_report_for("Reporte_QuiebresStock", "week_days").to_json)
    @pedidos = ActiveSupport::JSON.decode(Order.split_report_for("InfoPedidos", "week_days").to_json)
    @ventas = ActiveSupport::JSON.decode(Order.split_report_for("Reporte_Ventas", "week_days").to_json)
    @pedidos_incorrectos = ActiveSupport::JSON.decode(Order.split_report_for("Reporte_OrdenesIncorrectas", "week_days").to_json)
    render 'week'
  end

end
