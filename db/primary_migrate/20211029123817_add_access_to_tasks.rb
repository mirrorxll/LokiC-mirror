# frozen_string_literal: true

class AddAccessToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :access, :boolean, default: true, after: :deadline
  end
end
