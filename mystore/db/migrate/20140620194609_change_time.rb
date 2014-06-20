class ChangeTime < ActiveRecord::Migration
  def self.up
      remove_column :oferta,:initial_date, :time
      add_column :oferta,:initial_date, :datetime
      remove_column :oferta,:due_date, :time
      add_column :oferta,:due_date, :datetime
  end
  def self.down
      add_column :oferta,:initial_date, :time
      remove_column :oferta,:initial_date, :datetime
      add_column :oferta,:due_date, :time
      remove_column :oferta,:due_date, :datetime
  end
end
