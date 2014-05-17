class Connectors::WarehouseConnector
  class InvalidConfigurationException < Exception
  end

  def initialize()
    @server_address = ENV["WAREHOUSE_ADDRESS"]
    @conn = Faraday.new(:url => @server_address) do |faraday|
      faraday.request :json
      faraday.response :logger   
      faraday.response :json, :content_type => "application/json"               
      faraday.adapter  Faraday.default_adapter  
    end
  end
  #-------------------------- External Call Methods (Pedidos) --------------------------------

  def obtenerStock(sku_id)
    sku_stock = 0
    almacenes = getAlmacenes()
    almacenes.each do |almacen|
      if almacen["pulmon"] == true or (almacen["pulmon"]  == false and almacen["despacho"]  == false and almacen["recepcion"] == false )
        skus_with_stock = getSkusWithStock(almacen["_id"])
        if !skus_with_stock.nil? and  !skus_with_stock.empty? and !skus_with_stock.find { |h| h['_id'].to_s == sku_id.to_s }.nil?
          sku_products = getStock(almacen["_id"], sku_id)
          sku_products.each do |product|
            if product["despachado"] == false
              sku_stock += 1
            end
          end  
        end
      end
    end
    sku_stock
  end
  
  def realizarDespacho(sku_id, cantidad) 
    
  end

  #---------------------------HTTP Type Methods ----------------------------------------------

  def get(options={})
    Rails.logger.info "Attempting to GET to #{@server_address}#{options[:path]}"
    response = @conn.get do |req|                           
        req.url options[:path]
        req.params = options[:params] unless options[:params].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
    end
    JSON.parse response.body.to_json if response.status < 300
  end

  def post(options={})
    Rails.logger.info "Attempting to POST to #{@server_address}#{path}"
    response = @conn.post do |req|
        req.url options[:path]
        req.body = options[:body].to_json unless options[:body].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
      end
      JSON.parse response.body.to_json if response.status < 300
  end

  def delete(options={})
    Rails.logger.info "Attempting to DELETE to #{@server_address}#{path}"
    response = @conn.delete do |req|
        req.url options[:path]
        req.body = options[:body].to_json unless options[:body].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
      end
      JSON.parse response.body.to_json if response.status < 300
  end
  #-----------------------------Api Call Options Methods---------------------------------------------------

  def getAlmacenes()
    options = {
      :path => "/almacenes",
      :headers => generate_security_header("get")
    }
    get options
  end

  def getSkusWithStock(almacenId)
    options = {
      :path => "/skusWithStock",
      :headers => generate_security_header("get", [almacenId]),
      :params => {
        :almacenId => almacenId
      }
    }
    get options
  end

  def getStock(almacenId, sku)
    options = {
      :path => "/stock",
      :headers => generate_security_header("get", [almacenId,sku]),
      :params => {
        :almacenId => almacenId,
        :sku => sku
      }
    }
    get options
  end
  private
  def moverStock(productoId, almacenId) #almacen de destino, mueve stock de un almacen a otro
    options = {
      :path => "/moveStock",
      :headers => generate_security_header("post", [productoId,almacenId]),
      :params => {
        :almacenId => almacenId,
        :productoId => productoId
      }
    }
    post options
  end
  private
  def moverStockBodega(productoId, almacenId) #almacen de destino, mueve stock de una bodega a almacen de otra
    options = {
      :path => "/moveStockBodega",
      :headers => generate_security_header("post", [productoId,almacenId]),
      :params => {
        :almacenId => almacenId,
        :productoId => productoId
      }
    }
    post options
  end
  private
  def despacharStock(productoId, direccion, precio, pedidoId) #despacha los pedidos desde el sistema de despachos.
    options = {
      :path => "/stock",
      :headers => generate_security_header("delete", [productoId,direccion,precio,pedidoId]),
      :params => {
        :almacenId => almacenId,
        :productoId => productoId,
        :precio => precio,
        :pedidoId => pedidoId
      }
    }
    delete options
  end
  #----------------------------Helper Methods------------------------------------------------------------------------
  private
  def generate_security_header(http_method, params={})
    require 'digest/hmac'
    header = http_method.to_s.upcase
    params.each do |param|
      header += param.to_s
    end
    Rails.logger.info "Pre encoded Header: #{header}"
    encoded_header = Base64.encode64(Digest::HMAC.digest(header, ENV["WAREHOUSE_PRIVATE_KEY"], Digest::SHA1))
    Rails.logger.info "Header: #{encoded_header}"
    complete_header = "UC grupo8:"+encoded_header
    Rails.logger.info "Complete Header: "+complete_header
    complete_header
  end  
end