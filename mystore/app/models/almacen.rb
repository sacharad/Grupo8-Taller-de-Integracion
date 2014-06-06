class Almacen < ActiveRecord::Base
  # Metodo para buscar por nombre de almacen. Nombres pueden ser:
  # => general
  # => pulmon
  # => despacho
  # => recepcion
  def self.buscar(almacen_name)
    Almacen.find_by_name(almacen_name)
  end
end
