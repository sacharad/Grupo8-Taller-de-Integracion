class Order < ActiveRecord::Base

	belongs_to :client
	has_many :products, through: :order_products
	has_many :order_products, dependent: :destroy
	
end
