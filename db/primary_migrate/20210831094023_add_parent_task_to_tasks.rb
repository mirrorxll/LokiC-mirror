# frozen_string_literal: true

class AddParentTaskToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :parent_task, after: :reminder_frequency_id
  end
end
