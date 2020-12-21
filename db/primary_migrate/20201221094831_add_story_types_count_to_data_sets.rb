class AddStoryTypesCountToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_column :data_sets, :story_types_count, :integer
  end
end
