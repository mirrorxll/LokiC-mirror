# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :tags do |t|
      t.integer :pl_identifier
      t.string  :name
      t.timestamps
    end
  end
end
