class CreateOrderedLists < ActiveRecord::Migration[6.0]
  def change
    create_table :ordered_lists do |t|
      t.references :account, null: false, foreign_key: true
      t.string     :branch_name, null: false
      t.string     :grid_name, null: false
      t.integer    :position, null: false

      t.timestamps
    end
  end
end
