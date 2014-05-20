class CreateDropboxes < ActiveRecord::Migration
  def change
    create_table :dropboxes do |t|
      t.string :dropbox_token

      t.timestamps
    end
  end
end
