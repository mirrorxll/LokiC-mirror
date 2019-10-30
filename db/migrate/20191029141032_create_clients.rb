# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :clients do |t|
      t.integer :pipeline_index
      t.string  :name

      t.timestamps
    end
  end
end
