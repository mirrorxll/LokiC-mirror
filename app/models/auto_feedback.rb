# frozen_string_literal: true

class AutoFeedback < ApplicationRecord
  serialize :output, Hash

  has_many :auto_feedback_confirmations
  has_many :iterations, through: :auto_feedback_confirmations
end
