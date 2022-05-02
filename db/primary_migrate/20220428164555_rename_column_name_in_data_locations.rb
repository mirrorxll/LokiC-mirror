# frozen_string_literal: true

class RenameColumnNameInDataLocations < ActiveRecord::Migration[6.0]
  def change
    rename_column :table_locations, :name, :table_name
  end
end
