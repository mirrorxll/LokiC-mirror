class AddGatherTaskIdToStoryType < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :gather_task_id, :integer, after: :comment
  end
end
