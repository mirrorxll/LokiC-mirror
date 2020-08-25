# frozen_string_literal: true

class CreateEditorsFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :editors_feedback do |t|
      t.belongs_to :fact_checking_doc
      t.belongs_to :editor

      t.text :body, limit: 1.megabyte
      t.boolean :approval, default: false
      t.timestamps
    end
  end
end
