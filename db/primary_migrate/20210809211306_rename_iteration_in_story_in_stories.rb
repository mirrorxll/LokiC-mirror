# frozen_string_literal: true

class RenameIterationInStoryInStories < ActiveRecord::Migration[6.0]
  def change
    rename_column :stories, :iteration_id, :story_type_iteration_id
  end
end
