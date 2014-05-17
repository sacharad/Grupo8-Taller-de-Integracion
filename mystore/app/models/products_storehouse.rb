class ProductsStorehouse < ActiveRecord::Base

	belongs_to :product
	belongs_to :storehouse

end
