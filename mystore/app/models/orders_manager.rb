class OrdersManager < ActiveRecord::Base

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
			Rails.logger.info "1 pedido['Pedidos']" + p['Pedidos'].to_s
			#EN WINDOWS CAMBIAR ESTO POR: p[1]
			pedido = p["Pedidos"]
			Rails.logger.info "2 pedido['Pedidos']" + pedido.to_s
			vtiger_address = vtiger.getAddress(pedido["direccionId"])
			if vtiger_address.nil?
				Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in vtiger.getAddress(pedido["direccionID"]) execution. line 25'
				vtiger_address = "Direccion Invalida"
			end

			#~~~~~ Order.report_order(pedido) -->
			reporte = {
				"pedidoID" => pedido["pedidoID"], 
				"fecha" => pedido["fecha"],
				"hora" => pedido["hora"],
				"direccion" => vtiger_address,
				"rut" => pedido["rut"],
				"pedidos" => []
			}
			reporte_quiebre = reporte.dup
			if vtiger.checkClient(pedido["direccionID"], pedido["rut"])
				quiebre = false

				pedido["Pedido"].each do |pedidos|
					# ::> Revisar skus, generar reportes de quiebre y de despacho
					rep_indv = checkPedido(pedido["rut"], pedidos)
					if rep_indv["status"] == "quiebre"
						quiebre = true
						reporte_quiebre["pedidos"] << rep_indv
					else
						# ::> Despachar
						productos = @warehouse.getStock(Almacen.buscar("general")["almacen_id"], rep_indv["sku"])
						productos = productos.nil? ? 0 : productos.take(rep_indv["cantidad"].to_i)

						productos.each do |producto|
							@warehouse.realizarDespacho(producto["_id"], reporte["direccion"], rep_indv["precio"].to_i, pedido["pedidoID"])
						end
						Reserve.usarReserva(pedido["rut"], rep_indv["sku"].to_i, [rep_indv["reserva"].to_i, rep_indv["cantidad"].to_i].min)
						reporte["pedidos"] << rep_indv
					end
				end
				Rails.logger.info "Following report is for successful order delivery"
				Rails.logger.info reporte
				Rails.logger.info "Following report is for broken stock" if quiebre
				Rails.logger.info reporte_quiebre if quiebre
				#~~~~~ Order.report_sales(reporte) -->
				#~~~~~ Order.report_brokestock(reporte_quiebre) if quiebre -->
			else
				#~~~~~ Order.report_wrongorder(reporte) -->
			end
		end
	end

	def self.checkPedido (rut, pedidos)
		
		# ::> checkear la bodega y la reserva del pedido, retornar un reporte para el estado del
		#     pedido para este sku


		stock = @warehouse.obtenerStock(pedidos["sku"])
		total_res = Reserve.getReservas(pedidos["sku"].to_i)
		reserva_cliente = Reserve.getReserva(rut, pedidos["sku"].to_i)

		res = [stock, total_res].min
		single_res = [stock, reserva_cliente].min

		report = {
			"sku" => pedidos["sku"],
			"cantidad" => pedidos["cantidad"],
			"reserva" => single_res,
			#~~~~~ --X
			"precio" => 0
			#~~~~~ "precio" => Price.get_prices(pedidos["sku"]) -->
		}

		stock_dif = pedidos["cantidad"].to_i - stock + res - single_res
		unless stock_dif <=  0
			Rails.logger.info "Failed to supply order. Status for sku: stock #{stock}, Total reserve #{res}, Client reserve #{single_res}"
			extra = @warehouse.pedirOtraBodega(pedidos["sku"], stock_dif)[:cantidad_recibida]
			unless stock_dif - extra <= 0
				Rails.logger.info "Failed to retrieve enough stock from other warehouses. Needed #{stock_dif}, got #{extra}"
				report["status"] = "quiebre"
				return report
			end
		end
		report["status"] = "OK"
		return report
	
	end
end