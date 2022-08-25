# frozen_string_literal: true

class AddPresenceToTableLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :table_locations, :presence, :boolean, after: :verified
  end
end
