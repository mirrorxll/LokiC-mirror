# frozen_string_literal: true

class CreateTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :texts do |t|
      t.references :text, polymorphic: true

      t.text :body, limit: 16_777_215
    end
  end
end
