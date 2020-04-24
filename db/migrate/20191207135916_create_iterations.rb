# frozen_string_literal: true

class CreateIterations < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :iterations do |t|
      t.belongs_to :story_type

      t.boolean :population,            default: nil
      t.boolean :export_configurations, default: nil
      t.boolean :fcd_samples,           default: nil
      t.boolean :creation,              default: nil
      t.boolean :export,                default: nil
      t.timestamps
    end
  end
end
