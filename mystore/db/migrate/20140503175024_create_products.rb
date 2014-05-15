class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :expense
      t.string :sku
      t.attachment :image
      t.text :description
      t.string :brand

      t.timestamps
    end
  end
end
