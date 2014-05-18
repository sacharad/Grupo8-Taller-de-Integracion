class CreateOrdersSftps < ActiveRecord::Migration
  def change
    create_table :orders_sftps do |t|
      t.string :name

      t.timestamps
    end
  end
end
