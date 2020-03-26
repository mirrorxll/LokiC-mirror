# frozen_string_literal: true

class CreateStagingTables < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :staging_tables do |t|
      t.belongs_to :story_type
      t.string :name
      t.string :columns, limit: 6000
      t.string :indices, limit: 6000
      t.timestamps
    end
  end
end
