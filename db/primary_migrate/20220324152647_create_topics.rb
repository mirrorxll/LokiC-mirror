class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics do |t|
      t.string :external_lp_id, length: 36
      t.integer :kind
      t.string :description

      t.timestamps
    end
  end
end
