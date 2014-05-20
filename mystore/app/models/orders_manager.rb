class OrdersManager < ActiveRecord::Base

### ESTO NO ESTA LISTO, NO VA A FUNCIONAR

	def self.fetchOrders
		ftp = Connectors::SftpConnector.new
		vtiger = Connectors::VtigerConnector.new
		@warehouse = Connectors::WarehouseConnector.new

		ftp.getPedidosNuevos().each do |p| #asumo son pedidos nuevos/no resueltos
			#UBUNTU - CAMBIAR ESTO POR: 
			#pedido = p["Pedidos"]
			pedido = p[1]

			reporte = {
				"pedidoID" => pedido["pedidoID"], 
				"fecha" => pedido["fecha"],
				"hora" => pedido["hora"],
				"direccion" => vtiger.getAddress(pedido["direccionID"]),
				"rut" => pedido["rut"]
			}
			if vtiger.checkClient(pedido["direccionID"], pedido["rut"])
				quiebre = false

				reporte["pedidos"] = []			
				pedido["Pedido"].each do |pedidos|

					rep_indv = checkPedido(pedido["rut"], pedidos)

					quiebre = true if rep_indv["status"] == "quiebre"
					reporte["pedidos"] << rep_indv
				end
				unless quiebre
					reporte["pedidos"].each do |rep|
						rep.except!("status")
						puts "reporte: #{rep}"
						puts [rep["reserva"].to_i, rep["cantidad"].to_i].min
						#@warehouse.realizarDespacho(rep["sku"], reporte["direccion"], rep["precio"], pedido["pedidoID"])
						Reserve.usarReserva(pedido["rut"], rep["sku"].to_i, [rep["reserva"].to_i, rep["cantidad"].to_i].min)
					end
					#REPORTE MONGO: report_sales(reporte) if ENV["IN_PRODUCTION"] == "true" 	
				else
					#REPORTE MONGO: report_brokestock(reporte) if ENV["IN_PRODUCTION"] == "true"
				end
			#else
				#REPORTE MONGO: report_wrongorder(reporte) if ENV["IN_PRODUCTION"] == "true"
			end
			puts "reporte final: #{reporte}"
		end
	end

	def self.checkPedido (rut, pedidos)
		
		report = {}
		report["sku"] = pedidos["sku"]
		report["cantidad"] = pedidos["cantidad"]

		stock = @warehouse.obtenerStock(pedidos["sku"])
		res = stock == 0 ? 0 : Reserve.getReservas(pedidos["sku"].to_i) 
		single_res = pedidos["cantidad"].to_i > stock ? 0 : Reserve.getReserva(rut, pedidos["sku"].to_i)

		unless pedidos["cantidad"].to_i <=  stock - res + single_res
			report["status"] = "quiebre"
			#@warehouse.pedirOtraBodega(pedidos["sku"], pedidos["cantidad"] - stock) if res == 0
			puts report
			return report
		end

		report["reserva"] = single_res

		#report["precio"] = Pricing.getPrecio(pedidos["sku"])
		report["status"] = "OK"

		return report
	end
end