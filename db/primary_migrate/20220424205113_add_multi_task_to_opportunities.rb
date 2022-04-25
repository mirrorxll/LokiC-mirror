# frozen_string_literal: true

class AddMultiTaskToOpportunities < ActiveRecord::Migration[6.0]
  def change
    add_column :opportunities, :multi_tasks, :boolean, default: false, after: :agency_id
  end
end
