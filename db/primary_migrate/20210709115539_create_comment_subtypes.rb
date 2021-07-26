# frozen_string_literal: true

class CreateCommentSubtypes < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_subtypes do |t|
      t.belongs_to :comment

      t.string :name
      t.timestamps
    end
  end
end
