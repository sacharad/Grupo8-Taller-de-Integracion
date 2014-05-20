class ChangeProducts < ActiveRecord::Migration
  def self.up
      add_column :products, :model, :string

  end
  def self.down
      remove_column :products, :model, :string
  end
end
