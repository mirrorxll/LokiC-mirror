class CreateDataSetCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :data_set_categories do |t|
      t.string :name
      t.string :note

      t.timestamps
    end
  end
end
