# frozen_string_literal: true

class CreateTaskChecklist < ActiveRecord::Migration[6.0]
  def change
    create_table :task_checklists do |t|
      t.belongs_to :task
      t.boolean    :confirmed, default: false
      t.string     :description
    end
  end
end
