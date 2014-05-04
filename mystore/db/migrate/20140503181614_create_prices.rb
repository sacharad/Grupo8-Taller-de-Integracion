class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string :type
      t.integer :price
      t.date :update_date
      t.date :validity_date
      t.integer :disposition_expense
      t.integer :transfer_charge
      t.references :product

      t.timestamps
    end
  end
end
