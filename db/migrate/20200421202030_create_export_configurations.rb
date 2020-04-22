# frozen_string_literal: true

class CreateExportConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :export_configurations do |t|
      t.belongs_to :story_type,   index: false
      t.belongs_to :client,       index: false
      t.belongs_to :publication,  index: false

      t.integer :production_job_item
      t.integer :staging_job_item
      t.timestamps
    end

    add_index :export_configurations,
              %i[story_type_id client_id publication_id],
              name: :export_config_unique_index,
              unique: true
  end
end
