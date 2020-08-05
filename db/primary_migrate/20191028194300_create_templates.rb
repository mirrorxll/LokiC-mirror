# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.belongs_to :story_type

      t.text :body, limit: 16_777_215
      t.timestamps
    end
  end
end
