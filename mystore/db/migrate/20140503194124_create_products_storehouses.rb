class CreateProductsStorehouses < ActiveRecord::Migration
  def change
    create_table :products_storehouses do |t|
      t.references :product
      t.references :storehouse

      t.timestamps
    end
  end
end
