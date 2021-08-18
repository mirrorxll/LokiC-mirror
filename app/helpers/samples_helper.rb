# frozen_string_literal: true

module SamplesHelper
  def stories_alert(message)
    messages = [
      'Success. Samples have been created',
      'Success. Stories have been created',
      'Success. Stories have been removed'
    ]

    messages.include?(message) ? 'success' : 'danger'
  end
end
