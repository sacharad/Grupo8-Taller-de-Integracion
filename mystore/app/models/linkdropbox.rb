class Linkdropbox < ActiveRecord::Base
	require 'dropbox_sdk'

	def self.download_and_load_prices()    
		      	   	    	
				@dropbox_token = DropboxSession.deserialize(Linkdropbox.first.dropbox_token)
				client = DropboxClient.new(@dropbox_token)
				contents, metadata = client.get_file_and_metadata('Grupo8/DBPrecios.accdb')
				begin
				      open('DBPrecios.accdb', 'wb') {|f| f.puts contents }
				   
				     
				rescue
				      flash[:success] =  "Exception occured while downloading..."		

	    		end 

	    		Linkdropbox.import_prices_to_csv
	    		Price.set_prices
	end
	#This method convert accdb file to csv
	def self.import_prices_to_csv
		 cmd = "java -jar ./AccessReader.jar" 
 			`#{cmd}`
	end 

	#http://erikonrails.snowedin.net/?p=212

end
