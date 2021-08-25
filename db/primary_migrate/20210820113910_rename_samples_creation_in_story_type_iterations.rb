class RenameSamplesCreationInStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_type_iterations, :samples_creation, :samples
  end
end
