# frozen_string_literal: true

class ChangeRemovingFromPlInStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_type_iterations, :removing_from_pl, :purge_export
    change_column :story_type_iterations, :purge_export, :boolean, after: :export
  end
end
