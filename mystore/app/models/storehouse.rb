class Storehouse < ActiveRecord::Base

	has_many :products, through: :products_storehouses
	has_many :products_storehouses, dependent: :destroy
	
end
