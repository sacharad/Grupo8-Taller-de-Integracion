class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.string :code
      t.string :dispatch_address

      t.timestamps
    end
  end
end
