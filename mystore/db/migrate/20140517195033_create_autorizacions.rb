class CreateAutorizacions < ActiveRecord::Migration
  def change
    create_table :autorizacions do |t|
      t.string :grupo
      t.string :password

      t.timestamps
    end
  end
end
