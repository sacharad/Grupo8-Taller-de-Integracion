class Price < ActiveRecord::Base

	belongs_to :product

	def read_file_dbprecios

		database = Mdb.open(DBPrecios.accdb)

		# list tables in the database
		database.tables 

		# read the records in a table
		database[:Movies]

	end

end
