# frozen_string_literal: true

class ReviewersFeedback < ApplicationRecord
  default_scope { order(created_at: :desc) }
  serialize :approval, Hash

  belongs_to :fact_checking_doc
  belongs_to :reviewer, class_name: 'Account'

  has_rich_text :body

  def body
    rich_text_body || build_rich_text_body(body: read_attribute(:body))
  end
end
