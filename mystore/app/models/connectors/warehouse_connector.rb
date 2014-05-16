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
  #---------------------------HTTP Call Type Methods ----------------------------------------------
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
  def despacharStock(productoId, direccion, precio, pedidoId) #almacen de destino, mueve stock de una bodega a almacen de otra
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