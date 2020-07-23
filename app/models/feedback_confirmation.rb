# frozen_string_literal: true

class FeedbackConfirmation < ApplicationRecord
  belongs_to :iteration
  belongs_to :feedback
end