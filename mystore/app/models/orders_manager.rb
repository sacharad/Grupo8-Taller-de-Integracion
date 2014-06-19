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
			p = JSON.parse p
			# Rails.logger.info "1 pedido['Pedidos']" + p['Pedidos'].to_s
			#EN WINDOWS CAMBIAR ESTO POR: p[1]
			pedido = p["Pedidos"]
			# Rails.logger.info "2 pedido['Pedidos']" + pedido.to_s
			vtiger_address = vtiger.getAddress(pedido["direccionId"])
			if vtiger_address.nil?
				Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in vtiger.getAddress(pedido["direccionID"]) execution. line 25'
				vtiger_address = "Direccion Invalida"
			end

			info_pedido = {
				"pedidoID" => pedido["pedidoID"], 
				"fecha" => pedido["fecha"][1],
				"hora" => pedido["hora"],
				"direccion" => vtiger_address,
				"rut" => pedido["rut"],
				"pedidos" => []
			}

			if vtiger.checkClient(pedido["direccionID"], pedido["rut"])

				pedido["Pedido"].each do |pedidos|
					info_sku = checkPedido(pedido["rut"], pedidos)

					reporte = {
						"producto" => {
							"sku" => pedidos["sku"],
							"cantidad" => info_sku["Q_DESPACHO"] + info_sku["Q_QUIEBRE"]
						},
						"fecha" => info_pedido["fecha"],
						"hora" => info_pedido["hora"],
						"id_pedido_padre" => info_pedido["pedidoID"],
						"rut" => info_pedido["rut"],
						"direccion_despacho"  => info_pedido["direccion"]
					}

					Rails.logger.info "reporte ORDEN: #{reporte}"
					Order.report_order(reporte)

					if info_sku["Q_DESPACHO"] > 0
						reporte["producto"]["cantidad"] = info_sku["Q_DESPACHO"]
						reporte["precio_venta"] = info_sku["precio"]

						begin
							Rails.logger.info "Attempting to ship order..."

							productos = @warehouse.getStock(Almacen.buscar("general")["almacen_id"], pedidos["sku"])
							productos = productos.nil? ? 0 : productos.take(info_sku["Q_DESPACHO"].to_i)

							productos.each do |producto|
								@warehouse.realizarDespacho(producto["_id"], info_pedido["direccion"], info_sku["precio"].to_i, pedido["pedidoID"])
							end
							Reserve.usarReserva(pedido["rut"], pedidos["sku"].to_i, [info_sku["reserva"].to_i, info_sku["Q_DESPACHO"].to_i].min)
							Order.report_sales(reporte)
							Rails.logger.info "reporte VENTA: #{reporte}"
						rescue
						end
					end
					if info_sku["Q_QUIEBRE"] > 0
						reporte["producto"]["cantidad"] = info_sku["Q_QUIEBRE"]

						reporte.except!("direccion_despacho")

						Rails.logger.info "reporte QUIEBRE: #{reporte}"
						Order.report_brokestock(reporte)
					end
				end
				Rails.logger.info "Following report is for successful order delivery"
				Rails.logger.info reporte
				Rails.logger.info "Following report is for broken stock" if quiebre
				Rails.logger.info reporte_quiebre if quiebre
				#~~~~~ Order.report_sales(reporte) -->
				#~~~~~ Order.report_brokestock(reporte_quiebre) if quiebre -->
			else
				Order.report_wrongorder(pedido)
				Rails.logger.info "reporte ORDEN MAL: #{pedido}"
			end
		end
	end

	def self.checkPedido (rut, pedidos)
		
		stock = @warehouse.obtenerStock(pedidos["sku"])
		total_res = 0
		reserva_cliente = 0
		begin
			total_res = Reserve.getReservas(pedidos["sku"].to_i)
			reserva_cliente = Reserve.getReserva(rut, pedidos["sku"].to_i)
		rescue
		end

		res = [stock, total_res].min
		single_res = [stock, reserva_cliente].min

		begin
			precio = Price.get_prices(pedidos["sku"])
		rescue
			precio = 0
		end

		report = {
			"reserva" => single_res,
			"precio" => precio
		}

		despachable = [stock - res + single_res, pedidos["cantidad"].to_i].min
		if despachable < pedidos["cantidad"].to_i

			despachable = despachable < 0 ? 0 : despachable
			begin
				Rails.logger.info "Failed to supply order. Status for sku: stock #{stock}, Total reserve #{res}, Client reserve #{single_res}"
				extra = @warehouse.pedirOtraBodega(pedidos["sku"], pedidos["cantidad"].to_i - despachable)[:cantidad_recibida]
			
				Rails.logger.info "Asked for #{pedidos["cantidad"].to_i} - #{despachable} stock, got: #{extra}"

				despachable += extra
			rescue
			end
		end

		report["Q_DESPACHO"] = despachable
		report["Q_QUIEBRE"] = pedidos["cantidad"].to_i - despachable

		Rails.logger.info "Status for this order: To_sale: #{despachable}, Broke_stock: #{pedidos["cantidad"].to_i - despachable}"
		
		return report
	end

	def self.actualizarDisponibilidad (sku)
		warehouse = Connectors::WarehouseConnector.new

		stock = warehouse.obtenerStock(sku)
		total_res = Reserve.getReservas(sku.to_i)

		disponibilidad = [stock - total_res, 0].max

		json_response = {
			:disponible => disponibilidad > 0 ? true : false,
			:stock => disponibilidad
		}

		return json_response
	end

	def self.generarPedido (sku, cantidad)
		warehouse = Connectors::WarehouseConnector.new
		
		stock = warehouse.obtenerStock(sku)
		total_res = Reserve.getReservas(sku.to_i)

		#~~~~~ report = {} -->

		res = [stock, total_res].min

		stock_dif = cantidad.to_i - stock + res
		unless stock_dif <= 0
			Rails.logger.info "Failed to supply order. Status for sku: stock #{stock}, Total reserve #{res}, Client reserve #{single_res}"
			extra = warehouse.pedirOtraBodega(sku, stock_dif)[:cantidad_recibida]

			unless stock_dif - extra <= 0
				Rails.logger.info "Failed to retrieve enough stock from other warehouses. Needed #{stock_dif}, got #{extra}"
				
				json_response = {
					:exito => false,
					:cantidad_solicitada => cantidad
				}
				json_response[:cantidad_despachada] = stock_dif - extra <= cantidad ? cantidad - stock_dif : 0;
				
				return json_response
			end
		end
		#~~~~~ self.Despachar -->
		json_response = {
			:exito => true,
			:cantidad_solicitada  => cantidad,
			:cantidad_despachada => cantidad
		}

		return json_response
	end
end