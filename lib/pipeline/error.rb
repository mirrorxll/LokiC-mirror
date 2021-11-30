# frozen_string_literal: true

module Pipeline
  # Custom error class for rescuing
  # from all pipeline-api errors
  class Error < StandardError; end

  # raised when passed wrong environment name
  # instead of staging or production
  class EnvironmentError < Error
    def message
      'You can pass only :staging or :production'
    end
  end
end
