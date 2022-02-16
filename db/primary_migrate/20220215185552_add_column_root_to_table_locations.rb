# frozen_string_literal: true

class AddColumnRootToTableLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :table_locations, :root, :boolean, default: false, after: :name
  end
end
