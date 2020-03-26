# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :tags do |t|
      t.integer :pipeline_index
      t.string  :name
      t.timestamps
    end
  end
end
