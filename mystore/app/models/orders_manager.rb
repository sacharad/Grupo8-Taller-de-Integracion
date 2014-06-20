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

		pedidos_ftp.each do |p|
			p = JSON.parse p
			# Rails.logger.info "1 pedido['Pedidos']" + p['Pedidos'].to_s
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

					begin
						Order.report_order(reporte)
					rescue Exception => e
						Rails.logger.info "reporte ORDEN: #{reporte}"
					end

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
							Product.asignar_stock(pedidos["sku"], info_sku["Q_DESPACHO"])
						rescue
						end
						begin
							Order.report_sales(reporte)
						rescue Exception => e
							Rails.logger.info "reporte VENTA: #{reporte}"
						end
					end
					if info_sku["Q_QUIEBRE"] > 0
						reporte["producto"]["cantidad"] = info_sku["Q_QUIEBRE"]

						reporte.except!("direccion_despacho")
						begin
							Order.report_brokestock(reporte)
						rescue
							Rails.logger.info "reporte QUIEBRE: #{reporte}"
						end
					end
				end

			else
				begin
					Order.report_wrongorder(pedido)					
				rescue Exception => e
					Rails.logger.info "reporte ORDEN MAL: #{pedido}"
				end
			end
		end
	end

	def self.checkPedido (rut, pedidos)
		
		stock = @warehouse.obtenerStock(pedidos["sku"])
		begin
			total_res = Reserve.getReservas(pedidos["sku"].to_i)
			reserva_cliente = Reserve.getReserva(rut, pedidos["sku"].to_i)
		rescue
			total_res = 0
			reserva_cliente = 0
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

		despachable = [[stock - res + single_res, 0].max, pedidos["cantidad"].to_i].min
		if despachable < pedidos["cantidad"].to_i

			begin
				Rails.logger.info "Failed to supply order. Status for sku: stock #{stock}, Total reserve #{res}, Client reserve #{single_res}"
				extra = @warehouse.pedirOtraBodega(pedidos["sku"], pedidos["cantidad"].to_i - despachable)[:cantidad_recibida]
			
				Rails.logger.info "Asked for #{pedidos["cantidad"].to_i} - #{despachable} stock, got: #{extra}"

				despachable += extra
			rescue
			end
		end
		
		despachable = despachable > pedidos["cantidad"].to_i ? pedidos["cantidad"].to_i : despachable
		report["Q_DESPACHO"] = despachable
		report["Q_QUIEBRE"] = pedidos["cantidad"].to_i - despachable

		Rails.logger.info "Status for this order: To_sale: #{despachable}, Broke_stock: #{pedidos["cantidad"].to_i - despachable}"
		
		return report
	end

	# Métodos e-Commerce

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

	def self.generarPedido (sku, cantidad, direccion, precio)
		warehouse = Connectors::WarehouseConnector.new
		
		stock = warehouse.obtenerStock(sku)
		begin
			total_res = Reserve.getReservas(sku.to_i)
		rescue Exception => e
			total_res = 0
		end

		res = [stock, total_res].min

		despachable = [[stock - res, 0].max, cantidad].min
		if despachable < cantidad
			begin
				Rails.logger.info "Failed to supply order. Status for sku: stock #{stock}, Total reserve #{total_res}"
				extra = warehouse.pedirOtraBodega(sku, cantidad - despachable)[:cantidad_recibida]
				Rails.logger.info "Asked for #{cantidad} - #{despachable} stock, got: #{extra}"
				despachable += extra
			rescue
			end
		end

		#~~~~~ self.despachar -->
		begin
			Rails.logger.info "Attempting to ship order..."

			productos = warehouse.getStock(Almacen.buscar("general")["almacen_id"], sku)
			productos = productos.nil? ? 0 : productos.take(despachable)

			productos.each do |producto|
				warehouse.realizarDespacho(producto["_id"], direccion, precio.to_i, "pedido_web")
			end
			Product.asignar_stock(sku, despachable)
		rescue
		end
		json_response = {
			:exito => despachable == cantidad ? true : false,
			:cantidad_solicitada  => cantidad,
			:cantidad_despachada => despachable
		}

		Rails.logger.info "Response: #{json_response}"
		return json_response
	end
end