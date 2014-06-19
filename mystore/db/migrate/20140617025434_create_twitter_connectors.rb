class CreateTwitterConnectors < ActiveRecord::Migration
  def change
    create_table :twitter_connectors do |t|

      t.timestamps
    end
  end
end
