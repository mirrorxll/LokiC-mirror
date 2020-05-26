# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.boolean :population
      t.string  :population_args
      t.boolean :export_configurations
      t.boolean :story_samples
      t.string  :story_sample_ids
      t.boolean :creation
      t.boolean :purge_all_samples
      t.boolean :schedule
      t.string  :schedule_args
      t.boolean :export
      t.timestamps
    end
  end
end
