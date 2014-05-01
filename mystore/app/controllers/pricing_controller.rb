class PricingController < ApplicationController
	require 'dropbox_sdk'
	
	#Connection with Dropbox
	#http://webprogramming29.wordpress.com/2012/12/21/authorization-with-dropbox-in-ruby-on-rails-using-dropbox-sdk/

		# Asks for authorization to Dropbox's account for access from SmartBoard to the files on it repository.
	def authorize

		session[:return_to] = request.referer
		@dbsession = DropboxSession.new(DROPBOX_APP_KEY, DROPBOX_APP_KEY_SECRET)
		#serialize and save this DropboxSession
		session[:dropbox_session] = @dbsession.serialize
		#pass to get_authorize_url a callback url that will return the user here
		redirect_to @dbsession.get_authorize_url url_for(:action => 'callback')
	end
	
	# To callback for Dropbox authorization 
	# @Params : None
	# @Return : None
	# @Purpose : To callback for Dropbox authorization
	def callback
		@dbsession = DropboxSession.deserialize(session[:dropbox_session])
		@dbsession.get_access_token #we've been authorized, so now request an access_token
		session[:dropbox_session] = @dbsession1.serialize	

		flash[:success] = "You have successfully authorized with dropbox."

		#redirect_to session[:return_to]	
		redirect_to services_show_path
		#redirect_to root_path
		
	rescue 
		session[:dropbox_session] = nil
	    flash[:success] = "Failed to authorize"
		#redirect_to session[:return_to]	
		redirect_to services_show_path
	end # end of dropbox_callback action


	def read_prices
		
	    if session[:dropbox_session]  
		      	
		      	@dropbox_token = session[:dropbox_session]
		      	session.delete :dropbox_session 
				#authorize

				client = DropboxClient.new(@dropbox_token)
				contents, metadata = client.get_file_and_metadata('/Documentos/Franco Escobar.png')
				open('/Documentos/Franco Escobar.png', 'w') {|f| f.puts contents }
				redirect_to services_show_path
		end 
	end

	def create
  # some object you want to create
  # if the object.save is fine
  #   redirect_to object
  # else
  #   render new with the errors
  # end
	end

end

