# frozen_string_literal: true

class RemoveColumnsFromIterations < ActiveRecord::Migration[6.0]
  def change
    remove_column :iterations, :export_configurations
    remove_column :iterations, :export_configuration_counts
  end
end
