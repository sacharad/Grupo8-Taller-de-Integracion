class OrdersManager < ActiveRecord::Base

	def self.fetchWeb
		pedidos = Connectors::SpreeOrdersConnector.spree_fetch_orders()
		process(pedidos, "WEB")
	end

	def self.fetchOrders
		ftp = Connectors::SftpConnector.new		
		pedidos = ftp.getPedidosNuevos()
		process(pedidos, "FTP")
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

	private
		def self.process (lista_pedidos, tipo)
			vtiger = Connectors::VtigerConnector.new
			@warehouse = Connectors::WarehouseConnector.new

			if lista_pedidos.nil?
				Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in ftp.getPedidosNuevos() execution. line 15'
				return nil
			end

			Rails.logger.info lista_pedidos

			lista_pedidos.each do |p|
				Rails.logger.info p
				#p = JSON.parse p
				# Rails.logger.info "1 pedido['Pedidos']" + p['Pedidos'].to_s
				pedido = p["Pedidos"]
				# Rails.logger.info "2 pedido['Pedidos']" + pedido.to_s

				info_pedido = {
					"pedidoID" => pedido["pedidoID"], 
					"hora" => pedido["hora"],
					"rut" => pedido["rut"]
				}

				info_pedido["fecha"] = tipo == "FTP" ? pedido["fecha"][1] : pedido["fecha"]

				ejecutar = true

				if tipo == "FTP"
					vtiger_address = vtiger.getAddress(pedido["direccionId"])
					if vtiger_address.nil?
						Rails.logger.info 'ERROR self.fetchOrders in OrdersManager, received nil in vtiger.getAddress(pedido["direccionID"]) execution. line 25'
						vtiger_address = "Direccion Invalida"
					end
					info_pedido["direccion"] = vtiger_address

					ejecutar = vtiger.checkClient(pedido["direccionID"], pedido["rut"])
				else
					info_pedido["direccion"] = pedido["direccionID"]
				end

				if ejecutar
					Rails.logger.info pedido
					Rails.logger.info pedido["Pedido"]
					pedido["Pedido"].each do |pedidos|
						info_sku = checkPedido(pedido["rut"], pedidos, tipo)

						reporte = {
							"producto" => {
								"sku" => pedidos["sku"],
								"cantidad" => pedidos["cantidad"]
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
							
							begin
								precio = Price.get_prices(pedidos["sku"]) if tipo == "FTP"
							rescue
								precio = 0
							end

							reporte["precio_venta"] = tipo == "FTP" ? precio : pedidos["precio"]

							begin
								Rails.logger.info "Attempting to ship order..."

								productos = @warehouse.getStock(Almacen.buscar("general")["almacen_id"], pedidos["sku"])
								productos = productos.nil? ? 0 : productos.take(info_sku["Q_DESPACHO"].to_i)

								productos.each do |producto|
									@warehouse.realizarDespacho(producto["_id"], info_pedido["direccion"], reporte["precio_venta"].to_i, pedido["pedidoID"])
								end
								Reserve.usarReserva(pedido["rut"], pedidos["sku"].to_i, [info_sku["reserva"].to_i, info_sku["Q_DESPACHO"].to_i].min) unless tipo == "WEB"
								Product.asignar_stock(pedidos["sku"], info_sku["Q_DESPACHO"])
							rescue
							end

							begin
								Order.report_sales(reporte)
							rescue Exception => e
								Rails.logger.info "reporte VENTA: #{reporte}"
							end
						end
						if info_sku["Q_QUIEBRE"] > 0 and tipo == "FTP"
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

		def self.checkPedido (rut, pedidos, tipo)

			reserva_cliente = 0
			stock = @warehouse.obtenerStock(pedidos["sku"])
			begin
				total_res = Reserve.getReservas(pedidos["sku"].to_i)
				reserva_cliente = Reserve.getReserva(rut, pedidos["sku"].to_i) if tipo == "FTP"
			rescue
				total_res = 0
			end

			res = [stock, total_res].min
			single_res = [stock, reserva_cliente].min

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

			report = {
				"reserva" => single_res,
				"Q_DESPACHO" => despachable,
				"Q_QUIEBRE" => pedidos["cantidad"].to_i - despachable
			}

			Rails.logger.info "Status for this order: To_sale: #{despachable}, Broke_stock: #{pedidos["cantidad"].to_i - despachable}"

			return report
		end
end