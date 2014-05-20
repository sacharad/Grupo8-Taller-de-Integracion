class Product < ActiveRecord::Base

	has_one :price
	has_many :orders, through: :order_products
	has_many :order_products, dependent: :destroy
	has_many :storehouses, through: :products_storehouses
	has_many :products_storehouses, dependent: :destroy
	has_many :reserves
	

	def self.load(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			producto=Product.new(:sku=>item['sku'],:image_file_name=>item['imagen'],:brand=>item['brand'],:model=>item['modelo'],:description=>item['descripcion'],:normal_price =>item['precio']['normal'],:internet_price => item['precio']['internet'])
			producto.save
			item['categorias'].each do |cat|
				categoria=Category.new(:name => cat,:product_id =>producto.id)
				categoria.save
			end
		end
	end	

	def self.loadSpree(file)
		archivo=File.read(file)
		JSON.parse(archivo).each do |item|
			producto=Spree::Product.create(:name=>item['modelo'],:price=>item['precio']['internet'],:sku=>item['sku'],:description=>item['descripcion'],:shipping_category_id=>1)
			producto.available_on=Time.now
			producto.save
		end
	end	

end
