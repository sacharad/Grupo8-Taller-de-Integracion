class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.date :delivery_date
      t.timestamp :order_date
      t.references :client

      t.timestamps
    end
  end
end
