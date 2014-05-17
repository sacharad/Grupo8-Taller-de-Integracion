class CreateSftpConnectors < ActiveRecord::Migration
  def change
    create_table :sftp_connectors do |t|

      t.timestamps
    end
  end
end
