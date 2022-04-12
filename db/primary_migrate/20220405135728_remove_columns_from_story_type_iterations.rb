# frozen_string_literal: true

class RemoveColumnsFromStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    remove_column :story_type_iterations, :kill_population
    remove_column :story_type_iterations, :kill_story_samples
    remove_column :story_type_iterations, :kill_creation
    remove_column :story_type_iterations, :kill_schedule
    remove_column :story_type_iterations, :kill_export
    remove_column :story_type_iterations, :kill_removing_from_pl
  end
end
