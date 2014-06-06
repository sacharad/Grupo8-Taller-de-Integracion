class Almacen < ActiveRecord::Base
  def self.buscar(almacen_name)
    Almacen.find_by_name(almacen_name)
  end
end
