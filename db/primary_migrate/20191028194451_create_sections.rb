# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :sections do |t|
      t.integer :pl_identifier
      t.string  :name
      t.timestamps
    end
  end
end
