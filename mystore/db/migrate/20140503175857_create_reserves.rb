class CreateReserves < ActiveRecord::Migration
  def change
    create_table :reserves do |t|
      t.string :unit
      t.integer :amount
      t.date :date
      t.references :client
      t.references :product

      t.timestamps
    end
  end
end
