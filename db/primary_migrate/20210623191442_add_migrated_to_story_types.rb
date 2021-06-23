# frozen_string_literal: true

class AddMigratedToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :migrated, :boolean, after: :creating_export_configurations
  end
end
