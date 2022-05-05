# frozen_string_literal: true

class ChangeUniqIndexForTableLocations < ActiveRecord::Migration[6.0]
  def up
    remove_index :table_locations, name: :table_location
  end

  def down
    add_index :table_locations, %i[host_id schema_id table_name], name: 'table_location', unique: true
  end
end
