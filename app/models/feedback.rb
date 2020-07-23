# frozen_string_literal: true

class Feedback < ApplicationRecord
  serialize :output, Hash

  has_many :feedback_confirmations
  has_many :iterations, through: :feedback_confirmations
end
