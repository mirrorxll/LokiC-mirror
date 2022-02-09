# frozen_string_literal: true

class CreateTaskNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :task_notes do |t|
      t.belongs_to  :task
      t.belongs_to  :creator
      t.text        :body

      t.index %i[task_id creator_id],
              unique: true, name: 'tasks_creators_unique_index'
    end
  end
end
