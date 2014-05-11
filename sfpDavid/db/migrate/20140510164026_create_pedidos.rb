class CreatePedidos < ActiveRecord::Migration
  def change
    create_table :pedidos do |t|
      t.string :Fecha
      t.string :Hora
      t.string :Rut
      t.string :Fecha
      t.string :Sku
      t.string :CantidadUnidad

      t.timestamps
    end
  end
end
