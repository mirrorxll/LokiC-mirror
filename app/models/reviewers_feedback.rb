# frozen_string_literal: true

class ReviewersFeedback < ApplicationRecord
  belongs_to :fact_checking_doc
end
