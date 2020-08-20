# frozen_string_literal: true

class CreateReviewersFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :reviewers_feedback do |t|
      t.belongs_to :fact_checking_doc

      t.text :body, limit: 1.megabyte
      t.timestamps
    end
  end
end
