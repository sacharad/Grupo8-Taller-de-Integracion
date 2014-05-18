class Product < ActiveRecord::Base

	has_one :price
	has_many :orders, through: :order_products
	has_many :order_products, dependent: :destroy
	has_many :storehouses, through: :products_storehouses
	has_many :products_storehouses, dependent: :destroy
	has_many :reserves
	
end
