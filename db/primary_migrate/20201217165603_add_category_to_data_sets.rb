class AddCategoryToDataSets < ActiveRecord::Migration[6.0]
  def change
    change_table :data_sets do |t|
      t.belongs_to :category
    end
  end
end
