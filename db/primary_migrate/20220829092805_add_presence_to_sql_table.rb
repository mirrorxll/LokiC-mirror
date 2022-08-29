class AddPresenceToSqlTable < ActiveRecord::Migration[6.0]
  def change
    add_column :sql_tables, :presence, :boolean, default: true, after: :total_records
    add_column :schemas, :presence, :boolean, default: true, after: :visible
    remove_column :table_locations, :presence, :boolean
  end
end
