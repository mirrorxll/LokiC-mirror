# frozen_string_literal: true

class CreateReviewersFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :reviewers_feedback do |t|
      t.belongs_to :fact_checking_doc
      t.belongs_to :reviewer

      t.text :body, limit: 1.megabyte
      t.boolean :approval, default: false
      t.timestamps
    end
  end
end
