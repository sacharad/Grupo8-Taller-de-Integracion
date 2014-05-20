class Price < ActiveRecord::Base

	require 'csv'
	belongs_to :product

	def self.get_prices(sku)

		consulta = self.where("validity_date >= ? and update_date <= ? and sku = ?", Date.today, Date.today, sku)
		p = consulta.first
				
		if(p.nil?)
			return precio = Product.find_by_sku(sku).normal_price
		else 
			return p.price
		end
		
	end

	#this method set the prices in csv file and insert it in price model
	def self.set_prices

		lines = File.new("Data.csv").readlines		
		
		lines.each do |line|
		    values = line.strip.split(',')
		  	#values = lines[0].strip.split(',')
		  	#puts lines[0]
		  	#puts values
		  	#puts "--------"
		  	value = values[0]
		    id = value[1..-2].to_i
		  	value = values[1]
		    sku = value[1..-2].to_i
		  	precio_actual = self.where("id = ? and sku = ?", id, sku.to_s).first

		  	if(precio_actual.nil?)

			  	price = Price.new

			  	price.id = id
			    price.sku = sku.to_s
			    
			    value = values[2]
			    precio = value[1..-2].to_i
			    price.price = precio
			    

			    value = values[3]
			    value = value[1..-2].delete(" ")
			    fecha_actual = Date.strptime(value, "%m/%d/%Y")
			    price.update_date = fecha_actual
			    
			    
			    value = values[4]
			    value = value[1..-2].delete(" ")
			    fecha_vigente = Date.strptime(value, "%m/%d/%Y")
			    price.validity_date = fecha_vigente
			    
			    
			    value = values[5]
			    costo_produccion = value[1..-2].to_i
			    price.cost_production = costo_produccion
			    

			    value = values[6]
			    costo_transp = value[1..-2].to_i
			    price.transfer_charge = costo_transp
			    

			    value = values[7]
			    costo_almacenaje = value[1..-2].to_i
			    price.disposition_expense = costo_almacenaje
			    
			    price.save

			else

				precio_actual.sku = sku.to_s
			    

			    value = values[2]
			    precio = value[1..-2].to_i
			    precio_actual.price = precio
			    

			    value = values[3]
			    value = value[1..-2].delete(" ")
			    fecha_actual = Date.strptime(value, "%m/%d/%Y")
			    precio_actual.update_date = fecha_actual
			    
			    
			    value = values[4]
			    value = value[1..-2].delete(" ")
			    fecha_vigente = Date.strptime(value, "%m/%d/%Y")
			    precio_actual.validity_date = fecha_vigente
			    
			    
			    value = values[5]
			    costo_produccion = value[1..-2].to_i
			    precio_actual.cost_production = costo_produccion
			    

			    value = values[6]
			    costo_transp = value[1..-2].to_i
			    precio_actual.transfer_charge = costo_transp
			    

			    value = values[7]
			    costo_almacenaje = value[1..-2].to_i
			    precio_actual.disposition_expense = costo_almacenaje
			    
			    precio_actual.save

			end 
		end


	end 

end
