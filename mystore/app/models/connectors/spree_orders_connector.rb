class Connectors::SpreeOrdersConnector < ActiveRecord::Base



	def self.spree_fetch_orders

		orders = Spree::Order.all

		hash = []

		if !orders.nil?
			orders.each	do |f|
				if (!OrdersSpree.exists?(:name => f.number))
					rut = "web"
					fecha = DateTime.now.to_date
					hora = Time.now.strftime("%I:%M:%S %z")
					###############Direccion#####################
					direc = (Spree::Address.find(f.ship_address_id)).to_s
					direccionID = direc[(direc.to_s).index(':')+2..(-1)]
					array_pedido = 
					{ 	
						"Pedidos" => 
						{
							"fecha" => fecha,
							"hora" => hora,
							"rut" => rut,
							"direccionID" => direccionID
						}
					}
					sku_array = []
					f.line_items.all.each do |li|
						sku = li.variant.sku
						cantidad = li.quantity
						precio = Spree::Product.find(li.variant.product_id).price
						sku_array << 
						{
							"sku" => sku, "cantidad" => cantidad, "precio" => precio
						}
					end
					array_pedido["Pedidos"]["Pedido"]=sku_array
					hash.push(array_pedido)
					OrdersSpree.create(:name => f.number) if Rails.env.production?
				end
			end
			return hash
		end

	end






end
