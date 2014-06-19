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

	#example info: {"id_pedido_padre" => "12", fecha" => "12/03/2013", "hora" => "16:00", "rut" =>"171234560", "producto" => {"sku" => "US123", "cantidad" => 3}}
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

	#Metodo que entrega un ranking de los productos para la cola especificada (entraga un hash sku, cantidad de aparaciones)
	#Actualmente solo funciona para Ventas y quiebres de Stock
	def self.ranking_products(name_queue)
		ventas = get_report(name_queue)
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
