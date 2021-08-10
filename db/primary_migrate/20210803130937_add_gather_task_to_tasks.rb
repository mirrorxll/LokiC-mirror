# frozen_string_literal: true

class AddGatherTaskToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :gather_task, :string, after: :reminder_frequency_id
  end
end
