# frozen_string_literal: true

class AddMultiTaskToAgencies < ActiveRecord::Migration[6.0]
  def change
    add_column :agencies, :multi_tasks, :boolean, default: false, after: :partner
  end
end
