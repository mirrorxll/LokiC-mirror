# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.boolean :population
      t.string  :population_args
      t.boolean :creation
      t.boolean :export
      t.boolean :fcd_samples
      t.boolean :export_configurations
      t.timestamps
    end
  end
end
