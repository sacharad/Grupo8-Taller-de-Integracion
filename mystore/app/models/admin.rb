class Admin < ActiveRecord::Base
before_save :encrypt_password
  
attr_accessor :password
attr_accessor :password_confirmation


	def encrypt_password
    	if password.present?
      		self.password_salt = BCrypt::Engine.generate_salt
     		self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    	end
  	end

  	def self.authenticate(username_or_email, password)

      	user = find_by_username(username_or_email)

	  	if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
	    	user
	  	else
		    nil
		end
	end

end