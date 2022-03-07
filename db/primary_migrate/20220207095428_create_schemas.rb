# frozen_string_literal: true

class CreateSchemas < ActiveRecord::Migration[6.0]
  def up
    create_table :schemas do |t|
      t.belongs_to :host

      t.string :name
      t.string :visible, default: false
      t.timestamps
    end

    add_index :schemas, %i[host_id name]
  end

  def down
    drop_table :schemas
  end
end
