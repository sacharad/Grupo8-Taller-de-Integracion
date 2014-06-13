class Rabbitmq < ActiveRecord::Base
require "bunny"
	
	def self.ofertas
		lista_msj =get_msj("ofertas")
		list_hash =[]
		lista_msj.each do |msj|
			#Aqui se genera un hash con cada uno de los pametros que trae el mensaje
			hash = JSON.parse (msj)
			hash["inicio"] = Time.at(hash["inicio"]/1000]
			hash["fin"] = Time.at(hash["fin"]/1000]
			#Usar time.strftime("%Y-%m-%d") para extraer solo fecha o time.strftime("%H:%M:%S") para solo hora
			list_hash << hash
		end
	end 

	def self.reposicion
		lista_msj =get_msj("reposicion")
		list_hash =[]
		lista_msj.each do |msj|
			hash = JSON.parse (msj)
			hash["fecha"] = Time.at(hash["fecha"]/1000]
			list_hash << hash
			##Hacer algo con el metodo que me de Nacho
		end
	end 

	def self.publish(mensaje, nombre_cola)
		connect(nombre_cola)
		@x.publish(mensaje, :routing_key => @q.name)
		@conn.close

		rescue 
		@conn.close
	end
	
	private 
	def self.connect(queue_name)
		@conn = Bunny.new("amqp://cnkihpad:vTi4ULXrnhtl3WHjZVDRE9wujtYq9Tgk@tiger.cloudamqp.com/cnkihpad")
		@conn.start
		ch = @conn.create_channel
		@q  = ch.queue(queue_name, :auto_delete => true)
		@x  = ch.default_exchange
	end 

	def self.get_msj(nombre_cola)		
		connect(nombre_cola)		
		@m =[]
		if (nombre_cola =="ofertas")
			@q.subscribe do |delivery_info, metadata, payload|
				 @m  << payload.to_s
				 puts "Received #{payload} from #{nombre_cola} queue"
			end
		elsif (nombre_cola == "reposicion") 
				@m  << payload.to_s
			@q.subscribe do |delivery_info, metadata, payload|
				 puts "Received #{payload} from #{nombre_cola} queue"
			end
		elsif (nombre_cola == "prueba") 
			@q.subscribe do |delivery_info, metadata, payload|
				 #puts "Received #{payload} from #{nombre_cola} queue"
				 @m  << payload.to_s
				 puts "Received #{payload} from #{nombre_cola} queue"
			end			
		end
		@conn.close
		return @m
		
		rescue 
		@conn.close
	end 

end
