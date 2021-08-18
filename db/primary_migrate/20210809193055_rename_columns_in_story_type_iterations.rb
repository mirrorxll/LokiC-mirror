# frozen_string_literal: true

class RenameColumnsInStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_type_iterations, :story_samples, :samples
    rename_column :story_type_iterations, :story_sample_args, :sample_args
    rename_column :story_type_iterations, :purge_all_samples, :purge_stories
  end
end
