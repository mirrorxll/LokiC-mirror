# frozen_string_literal: true

class ReviewersFeedback < ApplicationRecord
  default_scope { order(created_at: :desc) }
  serialize :approval, Hash

  belongs_to :fact_checking_doc
  belongs_to :reviewer, class_name: 'Account'
end
