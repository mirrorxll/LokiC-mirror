# frozen_string_literal: true

class CreateLevels < ActiveRecord::Migration[6.0]
  def up
    create_table :levels do |t|
      t.string :name
      t.timestamps
    end

    %w[U.S. State Region Community].each { |lvl| Level.create!(name: lvl) }
  end

  def down
    drop_table :levels
  end
end
