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

    Rails.logger.info(grupo);
    Rails.logger.info(password_sha1_recibido);
    Rails.logger.info(almacen_otro_grupo_id);
    Rails.logger.info(sku);
    Rails.logger.info(cantidad);

    #-----Chequeo de autorización-------------------------
    if Autorizacion.find_by_grupo(grupo).nil?
      render :json => [:error => "Grupo no registra autorización o nombre de usuario incorrecto."].to_json and return
    elsif !Autorizacion.find_by_grupo(grupo).password_in?
      render :json => [:error => "Grupo no registra contraseña."].to_json and return
    else
      autorizacion_grupo = Autorizacion.find_by_grupo(grupo)
      password_grupo = autorizacion_grupo.password_in
      if grupo == "grupo2" #quieren con encriptacion sha1
        password_sha1_generado = Digest::SHA1.hexdigest(password_grupo)
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      elsif grupo == "grupo9" #quieren sin encriptar
        password_sha1_generado = password_grupo
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      elsif grupo == "grupo4" #quieren sin encriptar
        password_sha1_generado = password_grupo
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      elsif grupo == "grupo6" #quieren sin encriptar
        password_sha1_generado = password_grupo
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      elsif grupo == "grupo3" #quieren sin encriptar
        password_sha1_generado = password_grupo
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      elsif grupo == "grupo7" #sha1 sin hmac pa los 2 lados
        password_sha1_generado = Digest::SHA1.hexdigest(password_grupo)
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
      else
        password_sha1_generado = Digest::SHA1.hexdigest password_grupo
        if password_sha1_recibido != password_sha1_generado
          render :json => [:error => "Contraseña incorrecta."].to_json and return
        end
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
      productos = warehouse_conn.getStock(Almacen.buscar("general")["almacen_id"], sku)
      productos = productos.nil? ? 0 : productos.take(cantidad_a_despachar)
      productos.each do |producto|
        a = warehouse_conn.moverStock(producto["_id"], Almacen.buscar("despacho")["almacen_id"])
        if !a.nil? #Si hay error en mover el stock al almacen de despacho, pass
          b = warehouse_conn.moverStockBodega(producto["_id"], almacen_otro_grupo_id)
          if !b.nil? #Si hay error en despachar a otra bodega, pass
            cantidad_despachada += 1
          else
            warehouse_conn.moverStock(producto["_id"], Almacen.buscar("general")["almacen_id"])
          end
        end
      end
      render :json => [:SKU => sku.to_s, :cantidad => cantidad_despachada.to_i].to_json and return
    end
    
    

  end
end
