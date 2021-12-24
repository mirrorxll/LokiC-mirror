# frozen_string_literal: true

class CreateTaskChecklists < ActiveRecord::Migration[6.0]
  def change
    create_table :task_checklists do |t|
      t.belongs_to :task
      t.string     :description
    end
  end
end
