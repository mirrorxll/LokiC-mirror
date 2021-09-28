# frozen_string_literal: true

class CreateUnderwritingProject < ActiveRecord::Migration[6.0]
  def change
    create_table :underwriting_projects do |t|
      t.string :name
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
