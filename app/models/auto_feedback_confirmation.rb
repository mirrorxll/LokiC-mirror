# frozen_string_literal: true

class AutoFeedbackConfirmation < ApplicationRecord
  belongs_to :auto_feedback
  belongs_to :story_type_iteration
  belongs_to :sample, class_name: 'Story', optional: true
end
