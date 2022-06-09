class CreateAccessLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :access_levels do |t|
      t.string  :name
      t.json    :permissions
      t.timestamps
    end
  end
end
