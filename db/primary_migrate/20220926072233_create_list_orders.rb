class CreateListOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :list_orders do |t|
      t.references :account, null: false, foreign_key: true
      t.string     :branch
      t.string     :grid_name
      t.integer    :position

      t.timestamps
    end
  end
end
