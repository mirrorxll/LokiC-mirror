# frozen_string_literal: true

class AddOldNameToStagingTables < ActiveRecord::Migration[6.0]
  def change
    add_column :staging_tables, :old_name, :string, after: :name
  end
end
