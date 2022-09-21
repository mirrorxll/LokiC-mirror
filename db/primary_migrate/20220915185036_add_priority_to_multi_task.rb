# frozen_string_literal: true

class AddPriorityToMultiTask < ActiveRecord::Migration[6.0]
  def change
    add_column :multi_tasks, :priority, :integer, after: :done_at, default: 1
  end
end
