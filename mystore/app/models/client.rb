class Client < ActiveRecord::Base

	has_many :orders, dependent: :destroy
	has_many :reserves, dependent: :destroy
	
end
