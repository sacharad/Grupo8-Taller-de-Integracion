class CreateOferta < ActiveRecord::Migration
  def change
    create_table :oferta do |t|
      t.string :sku
      t.integer :price
      t.time :initial_date
      t.time :due_date

      t.timestamps
    end
  end
end
