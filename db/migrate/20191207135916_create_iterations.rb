# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.boolean :population
      t.string  :population_args
      t.boolean :samples
      t.string  :sample_ids
      t.boolean :creation
      t.boolean :export_configurations
      t.boolean :export
      t.timestamps
    end
  end
end
