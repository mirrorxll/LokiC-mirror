# frozen_string_literal: true

class CreateDataLocations < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :data_locations do |t|
      t.string :source,   default: ''
      t.string :dataset,  default: ''
      t.string :status,   default: ''
      t.string :note,     default: ''

      t.timestamps
    end
  end
end
