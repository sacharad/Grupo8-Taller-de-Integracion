class ChangeRevisado < ActiveRecord::Migration
  def self.up
  	add_column :oferta,:iniciado, :boolean, default: false
  	add_column :oferta,:terminado, :boolean, default: false
  end

  def self.down
  	remove_column :oferta,:iniciado, :boolean
  	remove_column :oferta,:terminado, :boolean
  end
end
