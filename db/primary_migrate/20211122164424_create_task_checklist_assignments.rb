# frozen_string_literal: true

class CreateTaskChecklistAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :task_checklist_assignments do |t|
      t.belongs_to :checklist, class_name: 'TaskChecklist'
      t.belongs_to :account
      t.boolean    :confirmed, default: false
    end
  end
end
