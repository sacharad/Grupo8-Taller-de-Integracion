class AutorizationChange < ActiveRecord::Migration
  def self.up
    rename_column :autorizacions, :password, :password_in
    add_column :autorizacions, :password_out, :string
  end
  def self.down
    rename_column :autorizacions, :password_in, :password
    remove_column :autorizacions, :password_out, :string
  end
end
