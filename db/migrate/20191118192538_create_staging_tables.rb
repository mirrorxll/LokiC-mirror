# frozen_string_literal: true

class CreateStagingTables < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :staging_tables do |t|
      t.belongs_to :story_type
      t.string :name
      t.timestamps
    end
  end
end
