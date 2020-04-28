# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      t.belongs_to :iteration
      t.belongs_to :output

      t.integer :pl_production_identifier
      t.integer :pl_staging_identifier
      t.date    :published_at
      t.boolean :backdated, default: false
      t.timestamps
    end
  end
end
