class CreateOrdersManagers < ActiveRecord::Migration
  def change
    create_table :orders_managers do |t|

      t.timestamps
    end
  end
end
