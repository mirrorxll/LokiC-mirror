# frozen_string_literal: true

class CreateTableLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :table_locations do |t|
      t.references :table_location, polymorphic: true, index: { name: 'table_location' }
      t.belongs_to :host
      t.belongs_to :schema

      t.string     :table_name
      t.boolean    :verified
      t.timestamps
    end
  end
end
