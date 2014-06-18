class CreateRabbitmqs < ActiveRecord::Migration
  def change
    create_table :rabbitmqs do |t|

      t.timestamps
    end
  end
end
