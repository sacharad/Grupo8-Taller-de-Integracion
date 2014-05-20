class ChangeReserves < ActiveRecord::Migration
  def self.up
      remove_column :reserves, :client_id, :integer
      add_column :reserves, :client_id, :string
      add_column :reserves, :responsible, :string
      rename_column :reserves, :unit, :sku
  end
  def self.down
      add_column :reserves, :client_id, :integer
      remove_column :reserves, :client_id, :string
      remove_column :reserves, :responsible, :string
      rename_column :reserves, :sku, :unit
  end
end
