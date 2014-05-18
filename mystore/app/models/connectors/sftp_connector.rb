class Connectors::SftpConnector

	def initialize
	end

	def getPedidosNuevos
		
		@sftpConn = Net::SFTP.start('integra.ing.puc.cl', 'grupo8', :password => 's3932ko')

		json_pedidos_nuevos = "".to_json

		#Si ya está en mi base de datos, ya lo procesamos
		@sftpConn.dir.foreach("/home/grupo8/Pedidos") do |entry|
	   		if(!OrdersSftp.exists?(:name => entry.name) && entry.name.length>3)
				direccion = "/home/grupo8/Pedidos/" << entry.name
	   			data = @sftpConn.download!(direccion)
	   			data_json = Hash.from_xml(data).to_json
	   			hash = JSON.parse(data_json)
	   			pedidos = hash["xml"]
	   			pedidos["Pedidos"]["pedidoID"] = entry.name[7..-5]
	   			json_pedidos_nuevos = json_pedidos_nuevos + pedidos.to_json.delete(' ')
	   			OrdersSftp.create(:name => entry.name) 
	   		else
	   			puts entry.name + " exists"
	   		end
	    end

	   	puts json_pedidos_nuevos

	end


end
