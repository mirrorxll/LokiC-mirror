# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.boolean :population, default: nil
      t.string  :population_args
      t.string  :population_jid

      t.boolean :creation, default: nil
      t.string  :creation_jid, default: nil

      t.boolean :export, default: nil
      t.boolean :export_jid, default: nil

      t.boolean :fcd_samples, default: nil
      t.boolean :export_configurations, default: nil
      t.timestamps
    end
  end
end
