# frozen_string_literal: true

class AddColumnsToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :creating_export_configurations, :boolean,
               after: :staging_table_attached
    add_column :story_types, :export_configurations_counts, :string,
               default: '{}', after: :creating_export_configurations
  end
end
