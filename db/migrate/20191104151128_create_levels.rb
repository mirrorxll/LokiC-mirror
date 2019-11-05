# frozen_string_literal: true

class CreateLevels < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :levels do |t|
      t.string :name

      t.timestamps
    end
  end
end
