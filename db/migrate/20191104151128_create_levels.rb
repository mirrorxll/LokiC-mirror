# frozen_string_literal: true

class CreateLevels < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :levels do |t|
      t.string :name
      t.timestamps
    end
  end
end
