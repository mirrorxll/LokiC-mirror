# frozen_string_literal: true

class RenameIterationsToStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_table :iterations, :story_type_iterations
  end
end
