class DropTaskChecklistAssignments < ActiveRecord::Migration[6.0]
  def change
    drop_table :task_checklist_assignments, if_exists: true
  end
end
