class AddStateToDataSets < ActiveRecord::Migration[6.0]
  def change
    change_table :data_sets do |t|
      t.belongs_to :state
    end
  end
end
