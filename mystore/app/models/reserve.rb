class Reserve < ActiveRecord::Base

	belongs_to :client
	belongs_to :product
	
	def self.log
			Rails.logger.info "Whenever funciona a las #{Time.now}"
			puts 'Hola'
			session= GoogleDrive.login("integra8.ing.puc@gmail.com","integra8.ing.puc.cl")
			#Chequear que no se cambie el nombre del archivo	
			ws=session.spreadsheet_by_title("ReservasG8").worksheets[0]
			#t = Reserve.new
			#t.sku=ws[5,1]
			#puts t.sku
			session.spreadsheet_by_title("ReservasG8").export_as_file("test.html")
		end

end
