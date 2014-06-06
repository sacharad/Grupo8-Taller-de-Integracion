class CreateAlmacens < ActiveRecord::Migration
  def change
    create_table :almacens do |t|
      t.string :name
      t.string :almacen_id

      t.timestamps
    end
  end
end
