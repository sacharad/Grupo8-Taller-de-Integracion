class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index

  end
  def despachar_producto_otra_bodega
    if params["usuario"].nil? or params["password"].nil? or params["almacen_id"].nil? or params["SKU"].nil? or params["cantidad"].nil?
      render :json => [:error => "No se entregaron los parametros requeridos."].to_json and return
    elsif params["cantidad"].to_i == 0
      render :json => [:error => "Cantidad a despachar incorrecta."].to_json and return
    end

    grupo = params["usuario"]
    password_sha1_recibido = params["password"]
    almacen_otro_grupo_id = params["almacen_id"]
    sku = params["SKU"]
    cantidad = params["cantidad"].to_i

    #-----Chequeo de autorización-------------------------
    if Autorizacion.find_by_grupo(grupo).nil?
      render :json => [:error => "Grupo no registra autorización o nombre de usuario incorrecto."].to_json and return
    elsif !Autorizacion.find_by_grupo(grupo).password?
      render :json => [:error => "Grupo no registra contraseña."].to_json and return
    else
      autorizacion_grupo = Autorizacion.find_by_grupo(grupo)
      password_grupo = autorizacion_grupo.password
      password_sha1_generado = Base64.encode64(Digest::HMAC.digest(password_grupo, ENV["WAREHOUSE_PRIVATE_KEY"], Digest::SHA1))
      if password_sha1_recibido != password_sha1_generado
        render :json => [:error => "Contraseña incorrecta."].to_json and return
      end
    end
    #-----Comienzo envío de productos a bodega externa ------
    warehouse_conn = Connectors::WarehouseConnector.new
    stock_sku = warehouse_conn.obtenerStock(sku).to_i
    Rails.logger.info "STOCK SKU: "+ stock_sku.to_s
    if stock_sku == 0
      render :json => [:SKU => sku.to_s, :cantidad => 0].to_json and return
    end
    reservas_sku = Reserve.getReservas(sku).to_i
    stock_consolidado = (stock_sku - reservas_sku)
    Rails.logger.info "STOCK CONSOLIDADO: "+ stock_consolidado.to_s
    if stock_consolidado <= 0
      render :json => [:SKU => sku.to_s, :cantidad => 0].to_json and return
    else
      cantidad_despachada = 0
      cantidad_a_despachar = stock_consolidado >= cantidad ? cantidad : stock_consolidado
      cantidad_a_despachar.times do
        a = warehouse_conn.moverStock(sku, ENV["ALMACEN_DESPACHO"])
        if !a.nil? #Si hay error en mover el stock al almacen de despacho, pass
          b = warehouse_conn.moverStockBodega(sku, almacen_otro_grupo_id)
          if !b.nil? #Si hay error en despachar a otra bodega, pass
            cantidad_despachada += 1
          end
        end
        
      end
      render :json => [:SKU => sku.to_s, :cantidad => cantidad_despachada.to_i].to_json and return
    end
    
    

  end
end
