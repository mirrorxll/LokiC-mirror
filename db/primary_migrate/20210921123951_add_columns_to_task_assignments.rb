# frozen_string_literal: true

class AddColumnsToTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    change_table :task_assignments do |t|
      t.boolean  :confirmed, default: false, after: :account_id
      t.datetime :confirmed_at, after: :confirmed
      t.decimal  :hours, scale: 2, precision: 6, after: :confirmed_at
      t.boolean  :done, default: false, after: :hours

      TaskAssignment.all.each do |task_assignment|
        task_assignment.update!(confirmed_at: task_assignment[:created_at].to_s, confirmed: true)
      end
    end
  end
end
