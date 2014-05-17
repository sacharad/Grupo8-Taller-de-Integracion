class OrdersManager < ActiveRecord::Base

### ESTO NO ESTA LISTO, NO VA A FUNCIONAR

	def self.fetchOrders
		ftp = Connectors::FTPConnector.new
		@vtiger = Connectors::VtigerConnector.new
		
		ftp.getPedidosNuevos().each do |p| #asumo son pedidos nuevos/no resueltos
			#check fecha?
			pedido = p["Pedidos"]
			if @vtiger.checkClient(pedido["direccionID"], pedido["rut"])
				pedido["Pedido"].each do |sub_pedido|
					check(pedido, sub_pedido)
				end
			end
		end
	end


#######-----LEER-------####
# Mongo y Princing no estan definidos
# El reporte de venta tiene que incluir el precio del producto

	def self.check (pedido, sub_pedido)

		warehouse = Connectors::WarehouseConnector.new

		order = {
			"rut" => pedido["rut"],
			"fecha" => pedido["fecha"],
			"producto" => {
				"sku" => sub_pedido["sku"],
				"cantidad" => sub_pedido["cantidad"]
			}
		}

		if sub_pedido["cantidad"] <= warehouse.obtenerStock(sub_pedido["sku"]) - Reserve.getReservas(sub_pedido["sku"]) + Reserve.getReserva(rut_cliente, sub_pedido["sku"])
			Reserve.usarReserva(pedido["rut"], sub_pedido["sku"], [Reserve.getReserva(rut_cliente, sub_pedido["sku"]), sub_pedido["cantidad"]].min)

			warehouse.realizarDespacho(sub_pedido["sku"], @vtiger.getAddress(pedido["direccionID"]), sub_pedido["cantidad"])
			
			order["precio"] = Pricing.getPrecio(sub_pedido["sku"])
			Mongo.ReportarVenta(order)
			return	

		elsif sub_pedido["cantidad"] > warehouse.obtenerStock(sub_pedido["sku"]) and Reserve.getReservas(sub_pedido["sku"]) == 0
			warehouse.pedirOtraBodega(sub_pedido["sku"], sub_pedido["cantidad"] - warehouse.obtenerStock(sub_pedido["sku"]))
		end

		Mongo.Report_BrokeStock(order)
	end
end
