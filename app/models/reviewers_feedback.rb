# frozen_string_literal: true

class ReviewersFeedback < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :fact_checking_doc
  belongs_to :reviewer, class_name: 'Account'
end
