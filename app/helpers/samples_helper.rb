# frozen_string_literal: true

module SamplesHelper
  def samples_alert(message)
    messages = [
      "Success. FCD's samples have been created",
      'Success. All samples have been created',
      'Success. All samples have been removed'
    ]

    messages.include?(message) ? 'success' : 'danger'
  end
end
