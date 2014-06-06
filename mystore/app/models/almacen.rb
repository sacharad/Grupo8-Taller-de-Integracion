class Almacen < ActiveRecord::Base
  # Metodo para buscar por nombre de almacen. Nombres pueden ser:
  # => general
  # => pulmon
  # => despacho
  # => recepcion
  def self.buscar(almacen_name)
    a = Almacen.find_by_name(almacen_name)
    if a.nil?
      Product.actualizarAlmacenes
      a = Almacen.find_by_name(almacen_name)
    end
    a
  end

end
