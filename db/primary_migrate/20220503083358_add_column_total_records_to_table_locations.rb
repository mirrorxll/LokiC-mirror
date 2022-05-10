# frozen_string_literal: true

class AddColumnTotalRecordsToTableLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :table_locations, :total_records, :bigint, after: :table_name
  end
end
