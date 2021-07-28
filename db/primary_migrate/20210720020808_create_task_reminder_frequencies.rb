# frozen_string_literal: true

class CreateTaskReminderFrequencies < ActiveRecord::Migration[6.0]
  def change
    create_table :task_reminder_frequencies do |t|
      t.string :name
      t.timestamps
    end
  end
end
