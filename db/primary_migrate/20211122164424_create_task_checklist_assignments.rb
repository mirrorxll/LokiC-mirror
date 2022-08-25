# frozen_string_literal: true

class CreateTaskChecklistAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :task_checklist_assignments do |t|
      t.belongs_to :task
      t.belongs_to :checklist
      t.belongs_to :account
      t.boolean    :confirmed, default: false
    end
  end
end
