class DropboxController < ApplicationController
require 'dropbox_sdk'
	
	#Connection with Dropbox
	#http://webprogramming29.wordpress.com/2012/12/21/authorization-with-dropbox-in-ruby-on-rails-using-dropbox-sdk/

	# Asks for authorization to Dropbox's account for access from SmartBoard to the files on it repository.
	def authorize
		@dbsession = nil
		@@dropbox_session = nil
		#session[:return_to] = request.referer
		@dbsession = DropboxSession.new(DROPBOX_APP_KEY, DROPBOX_APP_KEY_SECRET)
		puts DROPBOX_APP_KEY, DROPBOX_APP_KEY_SECRET
		#serialize and save this DropboxSession
		@@dropbox_session = @dbsession.serialize
		#pass to get_authorize_url a callback url that will return the user here
		redirect_to @dbsession.get_authorize_url url_for(:action => 'callback')
	end
	
	# To callback for Dropbox authorization 
	# @Params : None
	# @Return : None
	# @Purpose : To callback for Dropbox authorization
	def callback
		
		@dbsession = DropboxSession.deserialize(@@dropbox_session)
		@dbsession.get_access_token #we've been authorized, so now request an access_token
		@dropbox_session = @dbsession.serialize
		dropbox = Linkdropbox.new
		dropbox.dropbox_token = @dropbox_session
	    dropbox.save
		#read_prices(DropboxSession.deserialize(@dropbox_session))
		read_prices()
		flash[:success] = "You have successfully authorized with dropbox."

		redirect_to services_show_path

	#rescue 
		#session[:dropbox_session] = nil
	    #flash[:success] = "Failed to authorize"
		#redirect_to services_show_path

		#redirect_to session[:return_to]	
	end # end of dropbox_callback action


	def download_prices()    
		      	   	    	
				@dropbox_token = DropboxSession.deserialize(Linkdropbox.first.dropbox_token)
				client = DropboxClient.new(@dropbox_token)
				contents, metadata = client.get_file_and_metadata('Grupo8/DBPrecios.accdb')
				begin
				      open('public/jars/DBPrecios.accdb', 'wb') {|f| f.puts contents }
				   
				     
				rescue
				      flash[:success] =  "Exception occured while downloading..."		

	    		end 

	    		Linkdropbox.import_prices_to_csv	
	end

end
