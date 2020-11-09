# frozen_string_literal: true

class CreateExportConfigurations < ActiveRecord::Migration[6.0]
  def change
    env = %w[development test].include?(Rails.env) ? 'staging' : Rails.env

    create_table :export_configurations do |t|
      t.belongs_to :story_type
      t.belongs_to :publication
      t.belongs_to :tag
      t.belongs_to :photo_bucket

      t.integer "#{env}_job_item".to_sym
      t.boolean :skipped, default: false
      t.timestamps
    end

    add_index :export_configurations,
              %i[story_type_id publication_id],
              name: :export_config_unique_index,
              unique: true
  end
end
