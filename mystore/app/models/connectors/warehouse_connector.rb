class Connectors::WarehouseConnector
  class InvalidConfigurationException < Exception
  end
  require 'uri'
  require 'rest_client'
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
      #-----Solo se toma el stock que se encuentra en el almacen principal como stock disponible
      if almacen["pulmon"]  == false and almacen["despacho"]  == false and almacen["recepcion"] == false
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
  
  def realizarDespacho(productoId, direccion, precio, pedidoId) 
    if productoId.nil? or direccion.nil? or precio.nil? or pedidoId.nil?
      return false
    end
    if Rails.env.production?
      a = moverStock(productoId, Almacen.buscar("despacho")["almacen_id"])
      if !a.nil? #Si hay error en mover el stock al almacen de despacho, pass
        b = despacharStock(productoId, direccion, precio.to_i, pedidoId)
        if !b.nil? #Si hay error en despachar, pass
          return true
        else
          moverStock(productoId, Almacen.buscar("general")["almacen_id"])
          return false
        end
      else
        return false
      end
    else
      return true # Si esta en development o en test realizar un despacho es true si o si para no generar problemas de stock
    end
    
  end

  def pedirOtraBodega(sku,cantidad)
    cantidad_acumulada = 0
    cantidad = cantidad.to_i

    if Rails.env.production?
      Autorizacion.all.each do |a|
        if a.password_out? and a.grupo?
          cantidad_a_pedir = (cantidad_acumulada < cantidad) ? (cantidad - cantidad_acumulada) : 0
          if cantidad_a_pedir > 0
            begin
              warehouse_url = "http://integra"+a.grupo[a.grupo.length-1].to_s+".ing.puc.cl"

              @conn_otra_bodega = Faraday.new(:url => warehouse_url) do |faraday|
                faraday.request :json
                faraday.response :logger   
                faraday.response :json, :content_type => "application/json"               
                faraday.adapter  Faraday.default_adapter  
              end
              if a.grupo == "grupo9"
                options = {
                :path => "/api/pedirProducto/grupo8/#{a.password_out}/#{sku}",
                :warehouse_url => warehouse_url,
                :params => {
                  :almacenId => Almacen.buscar("recepcion")["almacen_id"],
                  :cantidad => cantidad_a_pedir
                }
              }
              elsif a.grupo == "grupo5"
              options = {
                :path => "/api/pedirProducto",
                :warehouse_url => warehouse_url,
                :params => {
                  :usuario => "grupo8",
                  :almacenId => Almacen.buscar("recepcion")["almacen_id"],
                  :password => a.password_out,
                  :sku => sku,
                  :cantidad => cantidad_a_pedir
                }
              }
              elsif a.grupo == "grupo2"
              options = {
                :path => "/api/pedirProducto",
                :warehouse_url => warehouse_url,
                :params => {
                  :usuario => "grupo8",
                  :almacen_id => Almacen.buscar("recepcion")["almacen_id"],
                  :password => Base64.encode64(Digest::HMAC.digest(a.password_out, ENV["WAREHOUSE_PRIVATE_KEY"], Digest::SHA1)),
                  :SKU => sku,
                  :cantidad => cantidad_a_pedir
                }
              }
              else
              options = {
                :path => "/api/pedirProducto",
                :warehouse_url => warehouse_url,
                :params => {
                  :usuario => "grupo8",
                  :almacen_id => Almacen.buscar("recepcion")["almacen_id"],
                  :password => Base64.encode64(Digest::HMAC.digest(a.password_out, ENV["WAREHOUSE_PRIVATE_KEY"], Digest::SHA1)),
                  :SKU => sku,
                  :cantidad => cantidad_a_pedir
                }
              }
              end
              respuesta = get_otra_bodega(options)
              cantidad_recibida = respuesta.nil? ? 0 : respuesta["cantidad"].to_i
              cantidad_acumulada += cantidad_recibida
            rescue => e
            end
          end
        end
      end
      json_response = {:cantidad_recibida => cantidad_acumulada }
      return json_response
    else
      return { :cantidad_recibida => 0 }
    end
  end

  def get_otra_bodega(options={})
    Rails.logger.info "Attempting to POST to #{options[:warehouse_url]}#{options[:path]}"
    Rails.logger.info "With Params: #{options[:params]}"
    Rails.logger.info @conn_otra_bodega.to_s
    response = @conn_otra_bodega.post do |req|                           
        req.url options[:path]
        req.body = options[:params] unless options[:params].nil?
    end
    if response.status < 300
      return JSON.parse response.body.to_json 
    else
      Rails.logger.info "GET WAREHOUSE PRODUCT FAILED(POST): "+response.body.to_s
      return nil
    end
  end

  def vaciar_almacen_recepcion()
    Rails.logger.info "STARTING clearance of almacen de recepcion"
    respuesta = Array.new 
    skus_recepcion = getSkusWithStock(Almacen.buscar("recepcion")["almacen_id"])
    skus_recepcion.each do |sku|
      sku_id = sku["_id"]
      sku_total = sku["total"]
      sku_stock = getStock(Almacen.buscar("recepcion")["almacen_id"], sku_id)
      total_despachado_sku = 0
      sku_stock.each do |producto|
        a = moverStock(producto["_id"], Almacen.buscar("general")["almacen_id"])
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
  #---------------------------HTTP Type Methods ----------------------------------------------

  def get(options={})
    Rails.logger.info "Attempting to GET to #{@server_address}#{options[:path]}"
    Rails.logger.info "With Params: "+options[:params].to_json.to_s unless options[:params].nil?
    response = @conn.get do |req|                           
        req.url options[:path]
        req.params = options[:params] unless options[:params].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
    end
    if response.status < 300
      return JSON.parse response.body.to_json 
    else
      Rails.logger.info "GET FAILED: "+response.body.to_s
      return nil
    end
  end

  def post(options={})
    Rails.logger.info "Attempting to POST to #{@server_address}#{options[:path]}"
    Rails.logger.info "With Params: "+options[:body].to_json.to_s unless options[:body].nil?
    response = @conn.post do |req|
        req.url options[:path]
        req.body = options[:body].to_json unless options[:body].nil?
        req.headers["Authorization"] = options[:headers] unless options[:headers].nil?
      end
    if response.status < 300
      return JSON.parse response.body.to_json 
    else
      Rails.logger.info "POST FAILED: "+response.body.to_s
      return nil
    end  end

  def delete(options={})
    Rails.logger.info "Attempting to DELETE to #{@server_address}#{options[:path]}"
    Rails.logger.info "With Params: "+options[:params].to_json.to_s unless options[:params].nil?
    response = @conn.delete options[:path] do |req|
        req.params = options[:params]
        req.headers["Authorization"] = options[:headers]
      end
    if response.status < 300
      return JSON.parse response.body.to_json 
    else
      Rails.logger.info "DELETE FAILED: "+response.body.to_s
      Rails.logger.info "DELETE FAILED: "+response.status.to_s
      return nil
    end  
  end
  def delete_rc(options={})
    Rails.logger.info "Attempting to DELETE to #{@server_address}#{options[:path]}"
    Rails.logger.info "With Params: "+options[:params].to_json.to_s unless options[:params].nil?
    begin
    response=RestClient::Request.execute(:method => 'delete', :url => "http://bodega-integracion-2014.herokuapp.com/stock",:headers =>{:Authorization => options[:headers]}, :payload =>options[:params])
    response = JSON.parse response
    return response
    rescue => e
      return nil
    end
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
      :body => {
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
      :body => {
        :almacenId => almacenId,
        :productoId => productoId
      }
    }
    post options
  end
  def despacharStock(productoId, direccion, precio, pedidoId) #despacha los pedidos desde el sistema de despachos.
    options = {
      :path => "/stock",
      :headers => generate_security_header("delete", [productoId,direccion,precio,pedidoId]),
      :params => {
        :precio => precio,
        :direccion => direccion,
        :productoId => productoId,
        :pedidoId => pedidoId
      }
    }
    delete_rc options
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