# frozen_string_literal: true

class CreateTableLocations < ActiveRecord::Migration[6.0]
  def up
    create_table :table_locations do |t|
      t.references :parent, polymorphic: true, index: { name: 'table_relation' }
      t.belongs_to :host
      t.belongs_to :schema

      t.string     :name
      t.boolean    :verified
      t.timestamps
    end

    add_index :table_locations, %i[host_id schema_id name], unique: true, name: 'table_location'
  end

  def down
    drop_table :table_locations
  end
end
