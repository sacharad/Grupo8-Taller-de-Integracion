class CreateLinkdropboxes < ActiveRecord::Migration
  def change
    create_table :linkdropboxes do |t|
      t.string :dropbox_token

      t.timestamps
    end
  end
end
