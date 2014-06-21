class Order < ActiveRecord::Base
	require 'mongo'
	require 'rubygems'
	include Mongo

	belongs_to :client
	has_many :products, through: :order_products
	has_many :order_products, dependent: :destroy

	/#Self. para disparar un metodo estatico/
	def self.insert_report (collection_name, report)
		#collection_name tiene el nombre de la coleccion
		#reporte corresponde al archivo que trae el reporte
		mongo_client = MongoClient.new("localhost", 27017)
		@db     = mongo_client.db("mongodb")
		coll = @db.collection(collection_name)
		coll.insert(report)
		
	end

	#example info: {"id_pedido_padre" => "12", "direccion_despacho"=>"calle patito", fecha" => "12/03/2013", "hora" => "16:00", "rut" =>"171234560", "producto" => {"sku" => "US123", "cantidad" => 3}}
	def self.report_order(order)
		insert_report("InfoPedidos",order)		 
		
	end

	#example sale: {"id_pedido_padre" => "12", "direccion_despacho"=>"calle patito",rut" =>"151234560", "fecha" => "13/06/2014", "hora" => "10:01", "precio_venta" => "52000", "producto" => {"sku" => "SKU45123", "cantidad" => 10}}
	def self.report_sales(sale)
		insert_report("Reporte_Ventas", sale)
		
	end

	#example info: {"id_pedido_padre" => "12","fecha" => "12/03/2013", "hora" => "16:00", "rut" =>"171234560", "producto" => {"sku" => "US123", "cantidad" => 3}}
	def self.report_brokestock(quiebre)

		insert_report("Reporte_QuiebresStock",quiebre)

	end

	def self.report_wrongorder(order)
		insert_report("Reporte_OrdenesIncorrectas",order)
	end


	def self.report_reposicion(replenish)
		insert_report("Reporte_Reposicion",replenish)
	end
	#Metodo que rentorna un hash que contiene un arreglo de los pedido. Estos pedidos son un hash también
	def self.get_complete_report(name_queue)
		hash = Hash.new
		hash["totales"] = get_report(name_queue)
		hash["ano"] = filter_report_for(name_queue, "year")
		hash["mes"] = filter_report_for(name_queue, "month")
		hash["semana"] = filter_report_for(name_queue, "week")
		hash["dia"] = filter_report_for(name_queue, "day")
		return hash
	end
	def self.get_complete_ranking_products(name_queue)
		hash = Hash.new
		hash["totales"] = ranking_products(name_queue, "totales")
		hash["ano"] = ranking_products(name_queue, "year")
		hash["mes"] = ranking_products(name_queue, "month")
		hash["semana"] = ranking_products(name_queue, "week")
		hash["dia"] = ranking_products(name_queue, "day")
		return hash
	end
	def self.get_complete_ranking_clients(name_queue)
		hash = Hash.new
		hash["totales"] = ranking_clients(name_queue, "totales")
		hash["ano"] = ranking_clients(name_queue, "year")
		hash["mes"] = ranking_clients(name_queue, "month")
		hash["semana"] = ranking_clients(name_queue, "week")
		hash["dia"] = ranking_clients(name_queue, "day")
		return hash
	end
	#InfoPedidos
	#Reporte_Ventas
	#Reporte_QuiebresStock
	#Reporte_OrdenesIncorrectas
	#Reporte_Reposicion
	def self.split_report_for(name_queue, option)
		splited_report= []
		if(option == "week_days")
			report = filter_report_for(name_queue, "week")
			date_initial= Date.today - 7.day
			i = 0
			7.times do
				splited_report[i]= Hash.new
				splited_report[i]["fecha"] = date_initial + i.day
				splited_report[i]["datos"] = []
	  	 		report.each do |item|
	  	 			fecha = Date.strptime(item["fecha"], "%Y-%m-%d")
		  	 		if(fecha == date_initial + i.day)
		  	 			splited_report[i]["datos"] << item	  	 
		  	 		end
	  	 		end
	  	 		i = i+1 
  	 		end
  	 	#for i in 1..5 do end
  	 	#5.times do end
		elsif(option == "month_days")
			report = filter_report_for(name_queue, "month")
			date_initial= Date.today - 30.day
			i = 0
			30.times do
				splited_report[i]= Hash.new
				splited_report[i]["fecha"] = date_initial + i.day
				splited_report[i]["datos"] = []
	  	 		report.each do |item|
	  	 			fecha = Date.strptime(item["fecha"], "%Y-%m-%d")
		  	 		if(fecha == date_initial + i.day)
		  	 			splited_report[i]["datos"] << item	  	 
		  	 		end
	  	 		end
	  	 		i = i+1 
  	 		end 
		elsif(option == "month")
			report = get_report(name_queue)
			date_initial= Date.today
			date = Date.today
			i = 0
			12.times do
				splited_report[i]= Hash.new
				splited_report[i]["fecha"] = date_initial - i.month
				splited_report[i]["datos"] = []
	  	 		report.each do |item|
	  	 			fecha = Date.strptime(item["fecha"], "%Y-%m-%d")
	  	 			if(fecha.month == date.month && fecha.year == date.year)
		  	 			splited_report[i]["datos"] << item	  	 
		  	 		end
	  	 		end
	  	 		i = i+1
	  	 		date = date_initial - i.month
  	 		end
  	 		splited_report.reverse
		else
			##nada
		end
		return splited_report
		
	end
	#Retorna una lista de hash para cada documento de una cola
	def self.get_report(name_queue)

	    ventas = Order.get_collection(name_queue) 
  	    @list_hash =[]
  	    ventas.find.each { |row|
  	 	    hash = JSON.parse (row.to_json)
  	 	    @list_hash << hash
  	 	}
  	 	return @list_hash
	end
	#Retorna una lista de hash para cada documento de una cola
	#filter puede ser "totales","año", "mes", "semana", "día"
	def self.filter_report_for(name_queue, filter)

	    ventas = Order.get_collection(name_queue) 
  	    @list_hash =[]
  	    ventas.find.each { |row|
  	 	    hash = JSON.parse (row.to_json)

  	 	    if(filter == "year")  	 	    	
  	 	    	fecha = Date.strptime(hash["fecha"], "%Y-%m-%d")
  	 	    	if(fecha.year ==  Date.today.year)
  	 	    		@list_hash << hash
  	 	    	end
  	 	    
  	 		elsif (filter == "month")
  	 			fecha = Date.strptime(hash["fecha"], "%Y-%m-%d")
  	 	    	if(fecha.month ==  Date.today.month)
  	 	    		@list_hash << hash
  	 	    	end

  	 		elsif (filter == "week")
  	 			fecha = Date.strptime(hash["fecha"], "%Y-%m-%d")
  	 			date_final= Date.today
  	 			date_initial= Date.today - 7.day
  	 	    	if(fecha >= date_initial && fecha <= date_final)
  	 	    		@list_hash << hash
  	 	    	end

  	 		elsif (filter == "day")
  	 			fecha = Date.strptime(hash["fecha"], "%Y-%m-%d")
  	 	    	if(fecha ==  Date.today)
  	 	    		@list_hash << hash
  	 	    	end
  	 		else
	  	 		 ##Esto equivale a filter == "totales"
	  	 		 @list_hash << hash

  	 		end 
  	 	   	 	
	    }
	    return @list_hash
		
	end

	#Metodo que entrega un ranking de los productos para la cola especificada (entraga un hash sku, cantidad de aparaciones)
	#Actualmente solo funciona para Ventas y quiebres de Stock
	def self.ranking_products(name_queue, filter)
		if(filter == "totales")
			ventas = get_report(name_queue)
		else
			ventas = filter_report_for(name_queue, filter)
		end
		hash = Hash.new
		ventas.each do |venta|
			sku = venta["producto"]["sku"]
			if hash[sku].nil?
				hash[sku] = 0			
			end
			
			hash [sku] = hash[sku] + 1 
			
		end
		ranking_ventas = hash.sort_by { |sku, value| value }.reverse
	end
	def self.ranking_clients(name_queue, filter)
		if(filter == "totales")
			ventas = get_report(name_queue)
		else
			ventas = filter_report_for(name_queue, filter)
		end
		hash = Hash.new
		ventas.each do |venta|
			rut = venta["rut"]
			if hash[rut].nil?
				hash[rut] = 0			
			end
			
			hash [rut] = hash[rut] + 1 
			
		end
		ranking_clientes = hash.sort_by { |rut, value| value }.reverse
		
	end


	##Metodos internos
	private

	def self.list_collection

		mongo_client = MongoClient.new("localhost", 27017)
		db     = mongo_client.db("mongodb")
		db.collection_names
	end 

	def self.get_collection(name)

		mongo_client = MongoClient.new("localhost", 27017)
		@db     = mongo_client.db("mongodb")
		coll = @db.collection(name)

	end

end
