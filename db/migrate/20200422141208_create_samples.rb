# frozen_string_literal: true

class CreateSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :samples do |t|
      t.belongs_to :iteration
      t.belongs_to :output
      t.belongs_to :publication

      t.integer :staging_row_id
      t.integer :pl_production_id
      t.integer :pl_staging_id
      t.date    :published_at
      t.boolean :backdated, default: false
      t.timestamps
    end
  end
end
