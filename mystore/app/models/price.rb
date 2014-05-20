class Price < ActiveRecord::Base

	require 'csv'
	belongs_to :product

	def get_prices(sku)

		consulta = self.where("validity_date >= ? and update_date <= ? and sku = ?", Date.today, Date.today, sku)
		p = consulta.first
				
		if(p.nil?)
			return precio = Product.find_by_sku(sku).nomal_price
		else 
			return p.price
		end
		
	end

	#This method convert accdb file to csv
	def self.import_prices_to_csv
		 cmd = "java -jar ./public/jars/AccessReader.jar" 
 			`#{cmd}`
	end 

	#http://erikonrails.snowedin.net/?p=212


	#this method 
	def self.set_prices

		lines = File.new("Data.csv").readlines
		
		
		lines.each do |line|
		    values = line.strip.split(',')
		  	#values = lines[0].strip.split(',')
		  	#puts lines[0]
		  	#puts values
		  	#puts "--------"
		  	price = Price.new
		    value = values[0]
		    id = value[1..-2].to_i
		    #puts id
		    #puts value
		    #puts "--------"

		    value = values[1]
		    sku = value[1..-2]
		    price.sku = sku
		    #puts sku
		    #puts value
		    #puts "--------"

		    value = values[2]
		    precio = value[1..-2].to_i
		    price.price = precio
		    #puts precio
		    #puts value
		    #puts "--------"

		    value = values[3]
		    value = value[1..-2].delete(" ")
		    fecha_actual = Date.strptime(value, "%m/%d/%Y")
		    price.update_date = fecha_actual
		    #puts fecha_actual
		    #puts value
		    #puts "--------"
		    
		    value = values[4]
		    value = value[1..-2].delete(" ")
		    fecha_vigente = Date.strptime(value, "%m/%d/%Y")
		    price.validity_date = fecha_vigente
		    #puts fecha_vigente
		    #puts value
		    #puts "--------"
		    
		    value = values[5]
		    costo_produccion = value[1..-2].to_i
		    price.cost_production = costo_produccion
		    #puts costo_produccion
		    #puts value
		    #puts "--------"

		    value = values[6]
		    costo_transp = value[1..-2].to_i
		    price.transfer_charge = costo_transp
		    #puts costo_transp
		    #puts value
		    #puts "--------"

		    value = values[7]
		    costo_almacenaje = value[1..-2].to_i
		    price.disposition_expense = costo_almacenaje
		    #puts cost_almacenaje
		    #puts value
		    #puts "--------"
		    price.save
		end


	end 

end
