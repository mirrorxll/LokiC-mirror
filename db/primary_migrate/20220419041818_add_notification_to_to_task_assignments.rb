# frozen_string_literal: true

class AddNotificationToToTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    add_column :task_assignments, :notification_to, :boolean, default: false, after: :main
  end
end
