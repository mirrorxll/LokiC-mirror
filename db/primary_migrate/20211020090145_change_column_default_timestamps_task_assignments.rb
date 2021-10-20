# frozen_string_literal: true

class ChangeColumnDefaultTimestampsTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:task_assignments, :created_at, nil)
    change_column_default(:task_assignments, :updated_at, nil)
  end
end
