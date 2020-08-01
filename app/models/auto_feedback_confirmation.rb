# frozen_string_literal: true

class AutoFeedbackConfirmation < ApplicationRecord
  belongs_to :iteration
  belongs_to :auto_feedback
end