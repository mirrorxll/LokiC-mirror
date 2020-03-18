# frozen_string_literal: true

class CreateStagingTables < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :staging_tables do |t|
      t.string  :name
      t.string  :editable, limit: 5000
      t.belongs_to :story_type

      t.timestamps
    end
  end
end
