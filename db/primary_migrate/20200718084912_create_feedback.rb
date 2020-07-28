# frozen_string_literal: true

class CreateFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :feedback do |t|
      t.string :rule
      t.text   :output
      t.timestamps
    end

    add_index :feedback, :rule, unique: true
  end
end
