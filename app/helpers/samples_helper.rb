# frozen_string_literal: true

module SamplesHelper
  def stories_alert(message)
    messages = [
      "Success. FCD's stories have been created",
      'Success. All stories have been created',
      'Success. All stories have been removed'
    ]

    messages.include?(message) ? 'success' : 'danger'
  end
end
