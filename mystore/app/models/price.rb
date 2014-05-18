class Price < ActiveRecord::Base

require "mdb"

	belongs_to :product


	def read_file_dbprecios

		#@database = Mdb.open('C:\Sites\Taller de integracion\Grupo8-Taller-de-Integracion\mystore\DBPrecios.accdb')
		@database = Mdb.open('DBPrecios.accdb')
		@pricing = @database.read("Pricing")

		# list tables in the database
		#database.tables 

		# read the records in a table
		#database[:Movies]

	end

end
