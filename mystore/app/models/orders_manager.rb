class OrdersManager < ActiveRecord::Base

### ESTO NO ESTA LISTO, NO VA A FUNCIONAR

	def self.fetchOrders
		ftp = Connectors::SftpConnector.new
		@vtiger = Connectors::VtigerConnector.new
		puts "-----1"
		ftp.getPedidosNuevos().each do |p| #asumo son pedidos nuevos/no resueltos


			 if @vtiger.checkClient(pedido["direccionID"], pedido["rut"])
				var = true
				pedido["Pedido"].each do |pedidos|
					var = checkPedidos(pedido, pedidos)
				end
				if var
					pedido["Pedido"].each do |pedidos|
						gestionarPedidos(pedido, pedidos)
					end
				end
			end
		end
	end

	def self.checkPedidos (pedido, pedidos)
		
		unless pedidos["cantidad"] <= warehouse.obtenerStock(pedidos["sku"]) - Reserve.getReservas(pedidos["sku"]) + Reserve.getReserva(rut_cliente, pedidos["sku"])
			return false
		end
	end

#######-----LEER-------####
# Mongo y Princing no estan definidos

	def self.gestionarPedidos (pedido, pedidos)

		warehouse = Connectors::WarehouseConnector.new

		order = {
			"rut" => pedido["rut"],
			"fecha" => pedido["fecha"],
			"producto" => {
				"sku" => pedidos["sku"],
				"cantidad" => pedidos["cantidad"]
			}
		}

		if pedidos["cantidad"] <= warehouse.obtenerStock(pedidos["sku"]) - Reserve.getReservas(pedidos["sku"]) + Reserve.getReserva(rut_cliente, pedidos["sku"])
			Reserve.usarReserva(pedido["rut"], pedidos["sku"], [Reserve.getReserva(rut_cliente, pedidos["sku"]), pedidos["cantidad"]].min)

			warehouse.realizarDespacho(pedidos["sku"], @vtiger.getAddress(pedido["direccionID"]), pedidos["cantidad"])
			
			order["precio"] = Pricing.getPrecio(pedidos["sku"])
			Mongo.ReportarVenta(order) if ENV["IN_PRODUCTION"] == "true"
			return	

		elsif pedidos["cantidad"] > warehouse.obtenerStock(pedidos["sku"]) and Reserve.getReservas(pedidos["sku"]) == 0
			warehouse.pedirOtraBodega(pedidos["sku"], pedidos["cantidad"] - warehouse.obtenerStock(pedidos["sku"]))
		end

		Mongo.Report_BrokeStock(order) if ENV["IN_PRODUCTION"] == "true"
	end
end