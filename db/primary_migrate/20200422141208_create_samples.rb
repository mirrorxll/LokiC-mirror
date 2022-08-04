# frozen_string_literal: true

class CreateSamples < ActiveRecord::Migration[6.0]
  def change
    env = %w[staging development test].include?(Rails.env) ? 'staging' : Rails.env

    create_table :samples do |t|
      t.belongs_to :iteration
      t.belongs_to :export_configuration
      t.belongs_to :client
      t.belongs_to :publication
      t.belongs_to :output
      t.belongs_to :time_frame

      t.integer     :staging_row_id
      t.string      :organization_ids, limit: 2000
      t.integer     "pl_#{env}_lead_id".to_sym
      t.integer     "pl_#{env}_story_id".to_sym
      t.date        :published_at
      t.datetime    :exported_at
      t.boolean     :backdated, default: false
      t.boolean     :sampled, default: false

      t.timestamps
    end
  end
end
