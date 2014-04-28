class PricingController < ApplicationController
	require 'dropbox_sdk'
	
	#Connection with Dropbox
	#http://webprogramming29.wordpress.com/2012/12/21/authorization-with-dropbox-in-ruby-on-rails-using-dropbox-sdk/

		# Asks for authorization to Dropbox's account for access from SmartBoard to the files on it repository.
	def authorize

		session[:return_to] = request.referer
		dbsession = DropboxSession.new(DROPBOX_APP_KEY, DROPBOX_APP_KEY_SECRET)
		#serialize and save this DropboxSession
		session[:dropbox_session] = dbsession.serialize
		#pass to get_authorize_url a callback url that will return the user here
		redirect_to dbsession.get_authorize_url url_for(:action => 'callback')
	end
	
	# To callback for Dropbox authorization 
	# @Params : None
	# @Return : None
	# @Purpose : To callback for Dropbox authorization
	def callback
		dbsession = DropboxSession.deserialize(session[:dropbox_session])
		dbsession.get_access_token #we've been authorized, so now request an access_token
		session[:dropbox_session] = dbsession.serialize	

		flash[:success] = "You have successfully authorized with dropbox."

		redirect_to session[:return_to]	
		
	rescue 
		session[:dropbox_session] = nil
	    flash[:success] = "Failed to authorize"
		redirect_to session[:return_to]	
	end # end of dropbox_callback action
end
