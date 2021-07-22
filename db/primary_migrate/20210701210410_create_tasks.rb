# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.belongs_to :creator
      t.belongs_to :status
      t.belongs_to :reminder_frequency

      t.string :title, limit: 1000
      t.text :description, limit: 16_777_215
      t.date :deadline
      t.date :done_at

      t.timestamps
    end
  end
end
