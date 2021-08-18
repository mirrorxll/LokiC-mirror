# frozen_string_literal: true

class RenameColumnInStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_type_iterations, :samples, :samples_creation
  end
end
