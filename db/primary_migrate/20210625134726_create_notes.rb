# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :texts do |t|
      t.string :text, limit: 2000
      t.timestamps
    end
  end
end
