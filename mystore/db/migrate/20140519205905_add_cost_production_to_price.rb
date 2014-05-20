class AddCostProductionToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :cost_production, :integer
  end
end
