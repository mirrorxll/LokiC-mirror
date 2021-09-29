# frozen_string_literal: true

class AddClientToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :client, after: :parent_task_id
  end
end
