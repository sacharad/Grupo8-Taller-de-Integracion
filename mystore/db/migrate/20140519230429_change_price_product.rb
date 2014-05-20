class ChangePriceProduct < ActiveRecord::Migration
  def self.up
      add_column :products, :normal_price, :integer
      add_column :products, :internet_price, :integer
  end
  def self.down
      remove_column :products, :normal_price, :integer
      remove_column :products, :internet_price, :integer
  end
end
