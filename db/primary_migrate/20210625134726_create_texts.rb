# frozen_string_literal: true

class CreateTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :texts do |t|
      t.string :text, limit: 500, index: true
      t.timestamps
    end
  end
end
