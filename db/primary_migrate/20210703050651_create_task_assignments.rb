# frozen_string_literal: true

class CreateTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :task_assignments do |t|
      t.belongs_to :task
      t.belongs_to :account

      t.index %i[task_id account_id],
              unique: true, name: 'tasks_accounts_unique_index'
    end
  end
end
