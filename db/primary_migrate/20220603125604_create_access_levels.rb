class CreateAccessLevels < ActiveRecord::Migration[6.0]
  def change
    create_table :access_levels do |t|
      t.belongs_to :branch

      t.string  :name
      t.json    :permissions
      t.timestamps
    end

    add_index :access_levels, %i[branch_id name], unique: true
  end
end
