# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :clients do |t|
      t.belongs_to :author

      t.integer :pl_identifier
      t.string  :name
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
