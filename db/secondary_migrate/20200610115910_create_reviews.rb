# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.string :report_type
      t.text :table

      t.timestamps
    end
  end
end
