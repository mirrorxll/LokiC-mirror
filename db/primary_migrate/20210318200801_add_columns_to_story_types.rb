# frozen_string_literal: true

class AddColumnsToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :creating_export_configurations, :boolean,
               after: :staging_table_attached
  end
end
