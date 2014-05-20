class OrdersManager < ActiveRecord::Base

### ESTO NO ESTA LISTO, NO VA A FUNCIONAR

	def self.fetchOrders
		ftp = Connectors::SftpConnector.new
		vtiger = Connectors::VtigerConnector.new
		@warehouse = Connectors::WarehouseConnector.new

		Rails.logger.info ftp.class
		Rails.logger.info ftp.to_s

		pedidos_ftp = ftp.getPedidosNuevos()
		if pedidos_ftp.nil?
			Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in ftp.getPedidosNuevos() execution. line 15'
			return nil
		end

		pedidos_ftp.each do |p| #asumo son pedidos nuevos/no resueltos
			Rails.logger.info p.to_s
			p = JSON.parse p
			Rails.logger.info "1 pedido['Pedidos']"+p['Pedidos'].to_s
			pedido = p["Pedidos"]
			Rails.logger.info "2 pedido['Pedidos']"+pedido.to_s
			vtiger_address = vtiger.getAddress(pedido["direccionId"])
			if vtiger_address.nil?
				Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in vtiger.getAddress(pedido["direccionID"]) execution. line 25'
				vtiger_address = "Direccion Invalida"
			end

			Order.report_order(pedido)

			reporte = {
				"pedidoID" => pedido["pedidoID"], 
				"fecha" => pedido["fecha"],
				"hora" => pedido["hora"],
				"direccion" => vtiger_address,
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

						productos = @warehouse.getStock(ENV["ALMACEN_LIBRE_DISPOSICION"], rep["sku"])
						productos = productos.nil? ? 0 : productos.take(rep["cantidad"].to_i)

						productos.each do |producto|
							@warehouse.realizarDespacho(producto["_id"], reporte["direccion"], rep["precio"].to_i, pedido["pedidoID"])
						end
						Reserve.usarReserva(pedido["rut"], rep["sku"].to_i, [rep["reserva"].to_i, rep["cantidad"].to_i].min)
					end
					Order.report_sales(reporte)	
				else
					Order.report_brokestock(reporte)
				end
			else
				Order.report_wrongorder(reporte)
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
		r = Reserve.getReserva(rut, pedidos["sku"].to_i)
		single_res = pedidos["cantidad"].to_i > stock ? 0 : Reserve.getReserva(rut, pedidos["sku"].to_i)

		unless pedidos["cantidad"].to_i <=  stock - res + single_res
			report["status"] = "quiebre"
			@warehouse.pedirOtraBodega(pedidos["sku"], (pedidos["cantidad"].to_i - stock)) if res == 0
			return report
		end

		report["reserva"] = single_res

		report["precio"] = Price.get_prices(pedidos["sku"])
		report["status"] = "OK"


		return report
	
	end
end