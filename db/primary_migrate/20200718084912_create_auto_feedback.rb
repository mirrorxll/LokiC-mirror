# frozen_string_literal: true

class CreateAutoFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :auto_feedback do |t|
      t.string :rule
      t.text   :output
      t.timestamps
    end

    add_index :auto_feedback, :rule, unique: true
  end
end
