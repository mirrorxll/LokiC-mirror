class AddTableIdToTableLocations < ActiveRecord::Migration[6.0]
  def change
    add_reference :table_locations, :sql_table, after: :schema_id
  end
end
