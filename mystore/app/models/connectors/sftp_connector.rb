class Connectors::SftpConnector

	def initialize
	end

	def getPedidosNuevos
		@sftpConn = Net::SFTP.start('integra.ing.puc.cl', 'grupo8', :password => 's3932ko')

		json_pedidos_nuevos = []


		#~~~~~ --X
		i = 0
		#~~~~~ --X

		#Si ya está en mi base de datos, ya lo procesamos
		@sftpConn.dir.foreach("/home/grupo8/Pedidos") do |entry|
	   		if(!OrdersSftp.exists?(:name => entry.name) && entry.name.length > 3)
	   			direccion = "/home/grupo8/Pedidos/" << entry.name
	   			data = @sftpConn.download!(direccion)
	   			data_json = Hash.from_xml(data).to_json
	   			hash = JSON.parse(data_json)
			   	fecha = hash["xml"]["Pedidos"]["fecha"][1]

			   	if Date.new(fecha[0..3].to_i,fecha[5..6].to_i,fecha[8..9].to_i) <= Date.today
		   			pedidos = hash["xml"]
		   			pedidos["Pedidos"]["pedidoID"] = entry.name[7..-5]
		   			json_pedidos_nuevos.push(pedidos.to_json.delete(' ')) 
		   			#~~~~~ OrdersSftp.create(:name => entry.name) {TEMP} -->
		   		end
	   		end
	   		#~~~~~ --X
	   		i == 10 ? break : i += 1
	   		#~~~~~ --X
	    end

		if json_pedidos_nuevos.first.nil?
			return nil
		else
			return json_pedidos_nuevos
		end
	end
end