class DashboardController < ApplicationController
  def index
  	@quiebres = Order.get_collection("Reporte_QuiebresStock").count.to_f
  	@pedidos = Order.get_collection("InfoPedidos").count.to_f
  	@ventas = Order.get_collection("Reporte_Ventas").count.to_f
  	@pedidos_incorrectos = Order.get_collection("Reporte_OrdenesIncorrectas").count.to_f

  end

  def show_sales
  	 ventas = Order.get_collection("Reporte_Ventas") 
  	 @list_hash =[]
  	 hash
  	 ventas.find.each { |row|
  	 	hash = JSON.parse (row.to_json)
  	 	@list_hash << hash
	 }
	 return @list_hash	
  end
  def show_brokestock

  	 ventas = Order.get_collection("Reporte_QuiebresStock") 
  	 @list_hash =[]
  	 hash
  	 ventas.find.each { |row|
  	 	hash = JSON.parse (row.to_json)
  	 	@list_hash << hash
	 }
	 return @list_hash	

  end

  def show_wrongorders

  	 ventas = Order.get_collection("Reporte_OrdenesIncorrectas") 
  	 @list_hash =[]
  	 hash
  	 ventas.find.each { |row|
  	 	hash = JSON.parse (row.to_json)
  	 	@list_hash << hash
	 }
	 return @list_hash	
  	
  end

end
