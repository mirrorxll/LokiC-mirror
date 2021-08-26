# frozen_string_literal: true

class RenamePurgeStoriesInStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_type_iterations, :purge_stories, :purge_creation
  end
end
