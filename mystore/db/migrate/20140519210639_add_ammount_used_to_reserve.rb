class AddAmmountUsedToReserve < ActiveRecord::Migration
  def self.up
      add_column :reserves, :ammount_used, :integer
  end
  def self.down
      remove_column :reserves, :ammount_used, :integer
  end
end
