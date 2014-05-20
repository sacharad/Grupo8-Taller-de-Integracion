class AddSkuToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :sku, :string
  end
end
