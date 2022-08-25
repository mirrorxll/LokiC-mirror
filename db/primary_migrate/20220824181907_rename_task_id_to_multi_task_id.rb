# frozen_string_literal: true

class RenameTaskIdToMultiTaskId < ActiveRecord::Migration[6.0]
  def change
    rename_column :scrape_tasks_tasks, :task_id, :multi_task_id
    rename_column :task_assignments, :task_id, :multi_task_id
    rename_column :task_checklists, :task_id, :multi_task_id
    rename_column :task_notes, :task_id, :multi_task_id
    rename_column :task_team_works, :task_id, :multi_task_id
    rename_column :tasks_agencies_opportunities_rv_ts, :task_id, :multi_task_id
  end
end
