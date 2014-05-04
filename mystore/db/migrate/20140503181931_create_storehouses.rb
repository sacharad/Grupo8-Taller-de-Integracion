class CreateStorehouses < ActiveRecord::Migration
  def change
    create_table :storehouses do |t|
      t.integer :capacity
      t.integer :type

      t.timestamps
    end
  end
end
