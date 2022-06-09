# frozen_string_literal: true

class CreateWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :work_types do |t|
      t.integer :work, index: true
      t.string  :name
      t.boolean :hidden, default: true
      t.timestamps
    end
  end
end
