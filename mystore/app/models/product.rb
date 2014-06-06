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
	def self.vaciar_almacen_recepcion
    Rails.logger.info "STARTING clearance of almacen de recepcion"
    conn = Connectors::WarehouseConnector.new
    respuesta = Array.new 
    skus_recepcion = conn.getSkusWithStock(Almacen.buscar("recepcion")["almacen_id"])
    skus_recepcion.each do |sku|
      sku_id = sku["_id"]
      sku_total = sku["total"]
      sku_stock = conn.getStock(Almacen.buscar("recepcion")["almacen_id"], sku_id)
      total_despachado_sku = 0
      sku_stock.each do |producto|
        a = conn.moverStock(producto["_id"], Almacen.buscar("general")["almacen_id"])
        if !a.nil?
          total_despachado_sku += 1
        else
          Rails.logger.info "FAILURE in warehouse_connector.vaciar_almacen_recepcion() in moverStock for sku: #{sku_id}, product: #{producto["_id"]}"
        end 

        if producto == sku_stock.last
          reporte_sku = {}
          reporte_sku[:sku] = sku_id
          reporte_sku[:total_enviado] = total_despachado_sku
          reporte_sku[:total_no_enviado] = sku_total - total_despachado_sku
          respuesta.push(reporte_sku)
        end
      end
    end  
    return respuesta  
  end

  #-----------------------------Actualization of Almacenes ---------------------------------------------------------

  def self.actualizarAlmacenes
    Rails.logger.info "STARTING actualizacion de almacenes en la BD"
    conn = Connectors::WarehouseConnector.new
    Almacen.destroy_all
    almacenes = conn.getAlmacenes()
    almacenes_a_guardar = []
    capacidad_general = 0
    almacenes.each do |almacen|
      almacen_id =  almacen["_id"]
      if almacen["pulmon"] == false and almacen["despacho"] == false and almacen["recepcion"] == false
        if almacen["totalSpace"].to_i > capacidad_general
          capacidad_general = almacen["totalSpace"].to_i
          almacenes_a_guardar.clear
          almacenes_a_guardar.push(almacen)
        end
      elsif almacen["pulmon"] == true and almacen["despacho"] == false and almacen["recepcion"] == false
        Almacen.create(:name => "pulmon", :almacen_id => almacen_id)
      elsif almacen["pulmon"] == false and almacen["despacho"] == true and almacen["recepcion"] == false
        Almacen.create(:name => "despacho", :almacen_id => almacen_id)
      elsif almacen["pulmon"] == false and almacen["despacho"] == false and almacen["recepcion"] == true
        Almacen.create(:name => "recepcion", :almacen_id => almacen_id)
      end
    end
    almacenes_a_guardar.each do |almacen|
      puts almacen
      Almacen.create(:name => "general", :almacen_id => almacen["_id"])
    end


  end

end
