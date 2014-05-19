class ChangePriceType < ActiveRecord::Migration
   def self.up
      rename_column :prices, :type, :tipo
  end
  def self.down
      rename_column :prices, :tipo, :type
  end
end
