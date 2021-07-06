# frozen_string_literal: true

class AddGatherTaskToStoryType < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :gather_task, :integer, after: :comment
  end
end
