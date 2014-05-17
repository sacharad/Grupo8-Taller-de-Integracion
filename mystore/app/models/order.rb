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
		db     = mongo_client.db("mongodb")
		coll = db.collection(collection_name)
		coll.insert(reporte)

	end

	def self.report_order(info)
		insert_report("InfoPedidos",info)		 
	end

	def self.report_sales
		
	end

	def self.report_BrokeStock

	end
	

	
end
