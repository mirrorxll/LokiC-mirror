# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :sections do |t|
      t.integer :pipeline_index
      t.string  :name
      t.timestamps
    end
  end
end
