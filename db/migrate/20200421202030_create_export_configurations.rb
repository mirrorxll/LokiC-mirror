# frozen_string_literal: true

class CreateExportConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :export_configurations do |t|
      t.belongs_to :story_type
      t.belongs_to :publication
      t.belongs_to :tag

      t.integer :production_job_item
      t.integer :staging_job_item
      t.boolean :skipped, default: false
      t.timestamps
    end

    add_index :export_configurations,
              %i[story_type_id publication_id],
              name: :export_config_unique_index,
              unique: true
  end
end
