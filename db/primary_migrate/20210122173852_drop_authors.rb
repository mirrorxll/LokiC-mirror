class DropAuthors < ActiveRecord::Migration[6.0]
  def change
    drop_table :authors, if_exists: true
  end
end
