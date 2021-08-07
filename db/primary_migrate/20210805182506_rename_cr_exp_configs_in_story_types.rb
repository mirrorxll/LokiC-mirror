# frozen_string_literal: true

class RenameCrExpConfigsInStoryTypes < ActiveRecord::Migration[6.0]
  def change
    rename_column :story_types,
                  :creating_export_configurations,
                  :export_configurations_created
  end
end
