# frozen_string_literal: true

class AddMainAssigneeToTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    add_column :task_assignments, :main_assignee, :boolean, default: false, after: :confirmed
  end
end
