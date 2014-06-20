class CreateOrdersSprees < ActiveRecord::Migration
  def change
    create_table :orders_sprees do |t|
      t.string :name

      t.timestamps
    end
  end
end
