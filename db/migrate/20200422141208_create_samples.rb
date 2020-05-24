# frozen_string_literal: true

class CreateSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :samples do |t|
      t.belongs_to :iteration
      t.belongs_to :export_configuration
      t.belongs_to :publication
      t.belongs_to :output
      t.belongs_to :time_frame

      t.integer     :staging_row_id
      t.date        :published_at
      t.string      :organization_ids, limit: 1000
      t.integer     :pl_production_id
      t.integer     :pl_staging_id
      t.date        :exported_at
      t.boolean     :backdated, default: false
      t.timestamps

      t.boolean :sampled
    end
  end
end
