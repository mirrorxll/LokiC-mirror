# frozen_string_literal: true

class CreatePriority < ActiveRecord::Migration[6.0]
  def change
    create_table :priorities do |t|
      t.string :name
      t.timestamps
    end
  end
end
