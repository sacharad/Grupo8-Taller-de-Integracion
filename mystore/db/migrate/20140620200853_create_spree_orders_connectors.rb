class CreateSpreeOrdersConnectors < ActiveRecord::Migration
  def change
    create_table :spree_orders_connectors do |t|

      t.timestamps
    end
  end
end
