# frozen_string_literal: true

class AddColumnTableColumnsToTableLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :table_locations, :table_columns, :text, after: :table_name
  end
end
