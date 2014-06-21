class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user,:force_login
  

    def current_user
	    @current_user ||= Admin.find(session[:user_id]) if session[:user_id]
	    rescue ActiveRecord::RecordNotFound
	end
	
	def force_login
	  	if(current_user)
	  	else
	   	 	redirect_to log_in_path  
	    	flash[:notice] = "Debe estar Logeado"
	    end
  	end

end
