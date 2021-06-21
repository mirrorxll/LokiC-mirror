# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.string  :name
      t.boolean :population
      t.string  :population_args
      t.boolean :story_samples
      t.string  :story_sample_args, limit: 1_000
      t.boolean :creation
      t.boolean :purge_all_samples
      t.boolean :schedule
      t.text    :schedule_args
      t.string  :schedule_counts, limit: 1_000
      t.boolean :export
      t.timestamps
    end
  end
end
