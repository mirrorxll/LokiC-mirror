# frozen_string_literal: true

class CreateTaskReceipts < ActiveRecord::Migration[6.0]
  def change
    create_table :task_receipts do |t|
      t.belongs_to :task
      t.belongs_to :assignment
      t.boolean    :confirmed, default: false
      t.timestamps

      t.index %i[task_id assignment_id],
              unique: true, name: 'tasks_assignments_unique_index'
    end
  end
end
