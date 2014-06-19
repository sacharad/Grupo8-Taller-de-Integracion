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
    self.load(file)
    tax_1=Spree::Taxonomy.create(name: "Marca")
    tax_2=Spree::Taxonomy.create(name: "Categoría")
    taxon_1=Spree::Taxon.create(name: "Marca", taxonomy_id: tax_1.id)
    taxon_2=Spree::Taxon.create(name: "Categoría", taxonomy_id: tax_2.id)
    archivo=File.read(file)
    JSON.parse(archivo).each do |item|
      producto=Spree::Product.create(:name=>item['modelo'],:price=>item['precio']['internet'],:sku=>item['sku'],:description=>item['descripcion'],:shipping_category_id=>1)
      producto.available_on=Time.now
      t=Spree::Taxon.create(name: item['marca'], parent_id: taxon_1, taxonomy_id: tax_1.id)
      t.save
      producto.taxons<<t
      item['categorias'].each do |categoria|
        t=Spree::Taxon.create(name: categoria, parent_id: taxon_2, taxonomy_id: tax_2.id)
        t.save
        producto.taxons<<t
      end 
      producto.save
      Spree::Image.create({:attachment => open(URI.parse(item['imagen'])),:viewable => producto.master})
    end
    setear_backorder
  end 

#------------------------------Metodos Spree----------------------------------------------------

  def self.setear_categoria
    Spree::Taxon.all.each do |tipo|
      if tipo.name!='Marca' or tipo.name!='Categoria' and tipo.taxonomy_id==1
        tipo.parent_id=1
        tipo.save
      elsif tipo.id!=1 and tipo.id!=2 and tipo.taxonomy_id==2
        tipo.parent_id=2
        tipo.save
      end  
    end
  end

  #Metodo que retorna el stock en spree de un sku determinado
  def self.find_stock(sku)
      t=Spree::Variant.find_by_sku(sku).id
      stock=Spree::StockItem.find_by_variant_id(t)
      return stock.count_on_hand
  end

  #Metodo que actualiza el stock de un sku determinado
  def self.actualizar_stock_producto(sku)
    t=Spree::Variant.find_by_sku(sku).product_id
    producto=Spree::Product.find(t)
    descripcion=producto.description
    producto.description=descripcion.split('<h3>')[0]+'<h3>Stock disponible: '+find_stock(sku).to_s+'</h3>'
    producto.save
  end

  #Metodo que cambia el precio de un producto en spree
  def self.change_price(sku,price)
    product_id=Spree::Variant.find_by_sku(sku).product_id
    producto=Spree::Product.find(product_id)
    producto.price=price
    producto.save
  end

  #Metodo que retorna precio internet al final de una promocion
  def self.terminar_promocion(sku)
    product_id=Spree::Variant.find_by_sku(sku).product_id
    producto=Spree::Product.find(product_id)
    producto.price=Product.find_by_sku(sku).internet_price
    producto.save
  end

  def self.setear_backorder
    Spree::StockItem.all.each do |item|
      item.backorderable=false
      item.save
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
