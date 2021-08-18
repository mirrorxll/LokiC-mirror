# frozen_string_literal: true

class AutoFeedback < ApplicationRecord
  serialize :output, Hash

  has_many :auto_feedback_confirmations
  has_many :story_type_iterations,
           through: :auto_feedback_confirmations
end
