class Reserve < ActiveRecord::Base

	belongs_to :client
	belongs_to :product
	
	def self.log
			#Rails.logger.info "Starting LOG method in Reserve Model. #{Time.now}"
			session= GoogleDrive.login("integra8.ing.puc@gmail.com","integra8.ing.puc.cl")
			#Chequear que no se cambie el nombre del archivo	
			conection=session.spreadsheet_by_title('ReservasG8').worksheets[0]
			session.spreadsheet_by_title('ReservasG8').export_as_file("test.html")
			return conection
	end


	#Metodo que entrega cantidad de productos reservados para un tipo de producto
	def self.getReservas(sku) 
		numReservas=0
		conection=self.log
		i=5
		#puts (Date.parse(conection[i,5]))>(Date.today-7.days)
		while conection[i,1]!=''
			if (Date.parse(conection[i,5]))>(Date.today-7.days)
				if conection[i,1].to_i==sku
					numReservas=numReservas+conection[i,3].to_i-conection[i,4].to_i
				end
				#puts conection[i,1] #elementos de spreadsheet se guardan en formato string
			end
		 	i=i+1
		end
		return numReservas
	end

	#Metodo que entrega cantidad de productos reservados para un tipo de producto. rutCliente debe ser ingresado como string (entre comillas)
	def self.getReserva(rutCliente, sku)
		numReservas=0
		conection=self.log
		i=5
		#puts (Date.parse(conection[i,5]))>(Date.today-7.days)
		while conection[i,1]!=''
			if (Date.parse(conection[i,5]))>(Date.today-7.days) and conection[i,1].to_i==sku and rutCliente==conection[i,2]
					numReservas=numReservas+conection[i,3].to_i - conection[i,4].to_i
				#puts conection[i,1] #elementos de spreadsheet se guardan en formato string
			end
		 	i=i+1
		end
		return numReservas
	end

	def self.usarReserva(rutCliente, sku,amount)
		numReduce=amount
		conection=self.log
		i=5
		#puts (Date.parse(conection[i,5]))>(Date.today-7.days)
		while numReduce>0
			while conection[i,1]!=''
				if (Date.parse(conection[i,5]))>(Date.today-7.days) and conection[i,1].to_i==sku and rutCliente==conection[i,2]
					if conection[i,3].to_i-conection[i,4].to_i>numReduce
						conection[i,4]=conection[i,4].to_i+numReduce
						numReduce=0
					else 
						numReduce=numReduce-(conection[i,3].to_i-conection[i,4].to_i)
						conection[i,4]=conection[i,3]
					end
					#puts conection[i,1] #elementos de spreadsheet se guardan en formato string
				end
		 		i=i+1
			end
		end
		conection.save
		return
	end
end
